## encoding: UTF-8

class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper
  include SessionsHelper

  before_filter :require_login
  before_filter :set_locale

  def set_locale
    # if params[:locale] is nil, then I18n.default_locale will be used
    I18n.locale = params[:locale]
  end

  private

    def sort_column(table_name)
      suggested_sort_column = params[table_name_to_sort_column_key(table_name)]
      table_name_to_class(table_name).column_names.include?(suggested_sort_column) ?
          suggested_sort_column.intern : default_sort_column(table_name)
    end

    def sort_direction(table_name)
      suggested_direction = params[table_name_to_sort_direction_key(table_name)]
      %w[asc desc].include?(suggested_direction) ? suggested_direction.intern : :asc
    end

end
