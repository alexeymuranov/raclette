require 'action_controller'
require 'csv'
require 'builder'
require 'zip/zip'

ActionController.add_renderer :collection_csv do |collection, options|
  self.content_type ||= Mime::CSV
  klass = collection.klass
  csv = AppRenderingHelpers::csv_from_collection(
    collection, options[:only], options[:headers])
  filename = options[:filename] ||
    "#{ klass.model_name.human.pluralize } " \
    "#{ Time.now.in_time_zone.strftime('%Y-%m-%d %k-%M') }.csv"
  send_data csv, :filename     => filename,
                 :content_type => "#{ Mime::CSV }; charset=utf-8",
                 :disposition  => 'inline'
end

ActionController.add_renderer :collection_ms_excel_2003_xml do |collection, options|
  self.content_type ||= Mime::MS_EXCEL_2003_XML
  klass = collection.klass
  if klass.include?(PseudoColumns)
    column_types = klass.column_db_types
  else
    column_types = {}
    attributes.each do |attr|
      column_types[attr] = klass.columns_hash[attr.to_s].type
    end
  end
  ms_excel_2003_xml =
    AppRenderingHelpers::ms_excel_2003_xml_from_collection(
      collection, options[:only], options[:headers])
  filename = options[:filename] ||
    "#{ klass.model_name.human.pluralize } " \
    "#{ Time.now.in_time_zone.strftime('%Y-%m-%d %k-%M') }.xls"
  send_data ms_excel_2003_xml,
            :filename     => filename,
            :content_type => "#{ Mime::MS_EXCEL_2003_XML }; charset=utf-8",
            :disposition  => 'inline'
end

ActionController.add_renderer :collection_csv_zip do |collection, options|
  self.content_type ||= Mime::CSV_ZIP
  klass = collection.klass
  csv = render_to_string({ :collection_csv => collection }.merge!(options))
  filename = options[:filename] ||
    "#{ klass.model_name.human.pluralize } " \
    "#{ Time.now.in_time_zone.strftime('%Y-%m-%d %k-%M') }.csv"
  data = AppRenderingHelpers::zip_string(csv, filename)
  send_data data,
            :filename     => "#{ filename }.zip",
            :content_type => "#{ Mime::CSV_ZIP }; charset=utf-8",
            :disposition  => 'attachment'
end

ActionController.add_renderer :collection_ms_excel_2003_xml_zip do |collection, options|
  self.content_type ||= Mime::MS_EXCEL_2003_XML_ZIP
  klass = collection.klass
  ms_excel_2003_xml =
    render_to_string(
      { :collection_ms_excel_2003_xml => collection }.merge!(options))
  filename = options[:filename] ||
    "#{ klass.model_name.human.pluralize } " \
    "#{ Time.now.in_time_zone.strftime('%Y-%m-%d %k-%M') }.xls"
  data = AppRenderingHelpers::zip_string(ms_excel_2003_xml, filename)
  send_data data,
            :filename     => "#{ filename }.zip",
            :content_type => "#{ Mime::MS_EXCEL_2003_XML_ZIP }; charset=utf-8",
            :disposition  => 'attachment'
end

module AppRenderingHelpers

  module_function

  def csv_from_collection(scoped_collection, attributes, column_headers)
    attributes ||= scoped_collection.klass.attribute_names
    CSV.generate(:col_sep       => ';',
                 :row_sep       => "\r\n",
                 :encoding      => 'utf-8') do |csv|
      csv << attributes.map { |attr| column_headers[attr] } << []
      scoped_collection.each do |model|
        csv << attributes.map { |attr| model.public_send(attr).to_s }
      end
    end
  end

  def ms_excel_2003_xml_from_collection(scoped_collection,
                                        attributes,
                                        column_headers)
    attributes ||= scoped_collection.klass.attribute_names
    klass = scoped_collection.klass
    if klass.include?(PseudoColumns)
      column_types = klass.column_db_types
    else
      column_types = {}
      attributes.each do |attr|
        column_types[attr] = klass.columns_hash[attr.to_s].type
      end
    end

    xml = ::Builder::XmlMarkup.new(:indent => 2)
    xml.instruct! :xml, :version    => '1.0',
                        :encoding   => 'UTF-8',
                        :standalone => 'yes'
    xml.instruct! 'mso-application', :progid => 'Excel.Sheet'

    xml.Workbook(
      'xmlns'    => 'urn:schemas-microsoft-com:office:spreadsheet',
      'xmlns:o'  => 'urn:schemas-microsoft-com:office:office',
      'xmlns:x'  => 'urn:schemas-microsoft-com:office:excel',
      'xmlns:ss' => 'urn:schemas-microsoft-com:office:spreadsheet') do

      xml.DocumentProperties :xmlns => 'urn:schemas-microsoft-com:office:office' do
        xml.Created Time.now.in_time_zone  # not known what would be the correct format
        xml.Language @locale.to_s          # FIXME: apparently this tag does not exist
      end

      xml.ExcelWorkbook :xmlns => 'urn:schemas-microsoft-com:office:excel'

      xml.Styles do
        xml.Style 'ss:ID' => 'MyTable'  # without any style boolean values are not interpreted correctly
        xml.Style 'ss:ID' => 'MyTableHeading' do
          xml.Font 'ss:Bold' => '1'
        end
      end

      xml.Worksheet 'ss:Name' => scoped_collection.klass.model_name.human.pluralize,
                    'ss:Lang' => @locale.to_s do  # FIXME: apparently 'ss:Lang' does not exist
        xml.Table 'ss:StyleID' => 'MyTable' do    # without any style boolean values are not shown correctly

          # Header
          xml.Row 'ss:StyleID' => 'MyTableHeading' do
            attributes.each do |attr|
              xml.Cell { xml.Data column_headers[attr], 'ss:Type' => 'String' }
            end
          end

          xml.Row  # a blank row

          # Rows
          scoped_collection.each do |mod|
            xml.Row do
              attributes.each do |attr|
                case column_types[attr]
                when :boolean
                  xml.Cell { xml.Data boolean_to_0_1(mod.public_send(attr)), 'ss:Type' => 'Boolean' }
                when :integer
                  xml.Cell { xml.Data mod.public_send(attr), 'ss:Type' => 'Number' }
                else
                  xml.Cell { xml.Data mod.public_send(attr), 'ss:Type' => 'String' }
                end
              end
            end
          end
        end
      end
    end
    xml.target!
  end

  def zip_string(string, filename)
    stringio = ::Zip::ZipOutputStream::write_buffer do |zip|
      zip.put_next_entry(filename)
      zip.write string
    end
    stringio.rewind
    stringio.sysread
  end

  def boolean_to_0_1(bool)
    bool ? 1 : 0
  end
end
