xml.instruct! :xml, :version    => '1.0',
                    :encoding   => 'UTF-8',
                    :standalone => 'yes'
xml.instruct! :'mso-application', :progid => 'Excel.Sheet'

xml.Workbook(
  'xmlns'    => 'urn:schemas-microsoft-com:office:spreadsheet', 
  'xmlns:o'  => 'urn:schemas-microsoft-com:office:office',
  'xmlns:x'  => 'urn:schemas-microsoft-com:office:excel',
  'xmlns:ss' => 'urn:schemas-microsoft-com:office:spreadsheet') do

  xml.DocumentProperties :xmlns => 'urn:schemas-microsoft-com:office:office' do
    xml.Created Time.now  # not known if this works
    xml.Lang @locale.to_s  # not known if this works
  end

  xml.ExcelWorkbook :xmlns => 'urn:schemas-microsoft-com:office:excel'

  xml.Styles do
    xml.Style 'ss:ID' => 'MyTable'  # otherwise boolean values are not interpreted correctly
    xml.Style 'ss:ID' => 'MyTableHeading' do
      xml.Font 'ss:Bold' => '1'
    end
  end

  xml.Worksheet 'ss:Name' => Admin::User.human_name.pluralize do
    xml.Table 'ss:StyleID' => 'MyTable' do  # without any style boolean values are not shown correctly

      # Header
      xml.Row 'ss:StyleID' => 'MyTableHeading' do
        @column_types_for_download_o_hash.each do |attr, col_type|
          xml.Cell { xml.Data Admin::User.human_attribute_name(attr), 'ss:Type' => 'String' }
        end
      end

      xml.Row  # a blank row

      # Rows
      @all_filtered_users.each do |user|
        xml.Row do
          @column_types_for_download_o_hash.each do |attr, col_type|
            case col_type
            when :boolean
              xml.Cell { xml.Data boolean_to_0_1(user.public_send(attr)), 'ss:Type' => 'Boolean' }
            else
              xml.Cell { xml.Data user.public_send(attr), 'ss:Type' => 'String' }
            end
          end
        end
      end
    end
  end
end