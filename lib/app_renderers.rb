# Created by Alexey on 2011-08-01

# require 'action_controller/metal/renderers'

# ActionController::Renderers.add :ms_excel_2003_xml do |template, options|  # FIXME
#   self.content_type ||= Mime::MS_EXCEL_2003_XML  # type registered in mime_types.rb
#   self.response_body  = template.respond_to?(:to_ms_excel_2003_xml) ? template.to_ms_excel_2003_xml(options) : template
# end

# ActionController::Renderers.add :csv do |csv, options|
#   self.content_type ||= Mime::CSV
#   self.response_body  = csv.respond_to?(:to_csv) ? csv.to_csv(options) : csv
# end
