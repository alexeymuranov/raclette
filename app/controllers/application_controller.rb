## encoding: UTF-8

class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper
  include SessionsHelper

  before_filter :require_login
  before_filter :set_locale

  helper_method :sort_column, :sort_direction

  def set_locale
    # if params[:locale] is nil, then I18n.default_locale will be used
    I18n.locale = params[:locale]
    @locale = I18n.locale
  end

  private

    def sort_column(table_name)
      params.deep_merge! :sort => { table_name => {} }

      suggested_sort_column = params[:sort][table_name][:column]

      table_name_to_class(table_name).column_names.include?(suggested_sort_column) ?
          suggested_sort_column.intern : default_sort_column(table_name)
    end

    def sort_direction(table_name)
      params.deep_merge! :sort => { table_name => {} }

      params[:sort][table_name][:direction] == 'desc' ? :desc : :asc
    end

    def sort_sql(table_name)
      "#{sort_column(table_name)} #{sort_direction(table_name)}"
    end

end
