# Created by Alexey on 2011-07-29
#
# require 'action_controller/metal/renderers'
# require 'action_controller/metal/responder'
#
# ActionController::Renderers.add :csv do |template, options|  # FIXME (not finished)
#   csv_string = FasterCSV.generate do |csv|
#     cols = ["column one", "column two", "column three"]
#
#     csv << cols
#
#     @entries.each do |entry|
#       csv << [entry.column_one, entry.column_two, entry.column_three ]
#     end
#   end
#
#   filename = I18n.l(Time.now, :format => :short) +
#              ' - ' + Admin::User.human_name.pluralize + '.csv'
#   send_data csv_string, :type     => 'text/csv; charset=utf-8; header=present',
#                         :filename => filename
# end
#
# ActionController::Renderers.add :xls do |template, options|  # FIXME (not finished)
#   book = Spreadsheet::Workbook.new
#   worksheet = book.create_worksheet(:name => Admin::User.human_name.pluralize)
# #
#   contruct_body(worksheet, @users)  # FIXME (not finished)
# #
#   blob = StringIO.new
#   book.write(blob)
# #
#   filename = I18n.l(Time.now, :format => :short) +
#              ' - ' + Admin::User.human_name.pluralize + '.xls'
#   send_data blob.string, :type     => 'application/vnd.ms-excel',
#                          :filename => filename
# end
#
#  class ActionController::Responder
#    def to_csv
#      controller.render :csv => controller.action_name
#    end
#
#   def to_xlsx
#     controller.render :xlsx => controller.action_name
#   end
# #
#   def to_xls
#     controller.render :xls => controller.action_name
#   end
#  end
