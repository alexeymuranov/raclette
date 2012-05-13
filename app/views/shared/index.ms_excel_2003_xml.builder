# Locals:
#   models:
#   attributes:
#   column_types:
#   column_headers:

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
    xml.Language @locale.to_s          # not known if this tag exists
  end

  xml.ExcelWorkbook :xmlns => 'urn:schemas-microsoft-com:office:excel'

  xml.Styles do
    xml.Style 'ss:ID' => 'MyTable'  # without any style boolean values are not interpreted correctly
    xml.Style 'ss:ID' => 'MyTableHeading' do
      xml.Font 'ss:Bold' => '1'
    end
  end

  xml.Worksheet 'ss:Name' => Admin::User.model_name.human.pluralize,
                'ss:Lang' => @locale.to_s do  # not known if 'ss:Lang' exists
    xml.Table 'ss:StyleID' => 'MyTable' do    # without any style boolean values are not shown correctly

      # Header
      xml.Row 'ss:StyleID' => 'MyTableHeading' do
        attributes.each do |attr|
          xml.Cell { xml.Data column_headers[attr], 'ss:Type' => 'String' }
        end
      end

      xml.Row  # a blank row

      # Rows
      models.each do |mod|
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
