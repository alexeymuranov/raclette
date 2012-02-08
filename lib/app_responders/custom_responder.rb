# NOTE: work in progress, not sure if this will actually be used
# See
# http://weblog.rubyonrails.org/2009/8/31/three-reasons-love-responder
# for information on custom responders

require_relative 'responding_paginated'
require_relative 'responding_csv'
require_relative 'responding_ms_excel_2003_xml'

class CustomResponder < ActionController::Responder
  include RespondingPaginated
  include RespondingCSV
  include RespondingMSExcel2003XML
end