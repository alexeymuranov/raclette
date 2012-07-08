# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone

Mime::Type.register 'application/xml', :ms_excel_2003_xml, [], ['xml.xls', 'xls']
Mime::Type.register 'application/vnd.ms-excel', :xls
# Mime::Type.register 'application/zip', :zip  # already initialized (standard)
Mime::Type.register 'application/zip', :ms_excel_2003_xml_zip, [], ['xls.zip', 'zip']
Mime::Type.register 'application/zip', :csv_zip, [], ['csv.zip', 'zip']
Mime::Type.register 'application/x-gzip', :gzip
Mime::Type.register 'application/x-gzip', :ms_excel_2003_xml_gzip, [], ['xls.gzip', 'xls.gz', 'gzip', 'gz']
Mime::Type.register 'application/x-gzip', :csv_gzip, [], ['csv.gzip', 'csv.gz', 'gzip', 'gz']
# Mime::Type.register 'application/pdf', :pdf
# Mime::Type.register 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', :xlsx
# Mime::Type.register 'application/vnd.oasis.opendocument.spreadsheet', :ods
