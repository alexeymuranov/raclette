## encoding: UTF-8

require 'csv'  # to render CSV

class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper
  include SessionsHelper

  before_filter :require_login
  before_filter :set_locale

  helper_method :sort_column, :sort_direction

  private

    def set_locale  # before filter
      # if params[:locale] is nil, then I18n.default_locale will be used
      I18n.locale = params[:locale]
      @locale = I18n.locale
    end

    def render_ms_excel_2003_xml_for_download(klass,
                                              models,
                                              attributes,
                                              column_types)
      send_data render_to_string(
          :template => 'shared/index',
          :locals   =>
              { :models       => models,
                :attributes   => attributes,
                :column_types => column_types }),
          :filename    => "#{klass.human_name.pluralize}"\
                          " #{Time.now.strftime('%Y-%m-%d %k_%M')}"\
                          ".excel2003.xml",
          :type        => "#{Mime::MS_EXCEL_2003_XML.to_s}; "\
                          "charset=utf-8",
          :disposition => 'inline'
    end

    def render_csv_for_download(klass, models, attributes_for_download)
      send_data csv_from_collection(klass, models,
                                    :only => attributes_for_download),
                :filename    => "#{klass.human_name.pluralize}"\
                                  " #{Time.now.strftime('%Y-%m-%d %k_%M')}"\
                                  ".csv",
                :type        => "#{Mime::CSV.to_s}; charset=utf-8",
                :disposition => 'inline'
    end

    def csv_from_collection(klass, collection, options={})
      columns = klass.columns.map(&:name).map(&:intern)
      columns &= Array.wrap(options[:only]) unless options[:only].nil?
      columns -= Array.wrap(options[:except]) unless options[:except].nil?

      CSV.generate(:col_sep       => ';',
                   :row_sep       => "\r\n",
                   :encoding      => 'utf-8',
                   :headers       => true,
                   :write_headers => true) do |csv|
        csv << columns.map { |col| klass.human_attribute_name(col) } << []
        collection.each do |model|
          csv << columns.map { |col| model.public_send(col).to_s }
        end
      end
    end

    def sort_column(table_name)
      params.deep_merge! :sort => { table_name => {} }

      suggested_sort_column = params[:sort][table_name][:column]

      table_name_to_class(table_name).column_names.include?(\
          suggested_sort_column) ?
          suggested_sort_column.intern : default_sort_column(table_name)
    end

    def sort_direction(table_name)
      params.deep_merge! :sort => { table_name => {} }

      params[:sort][table_name][:direction] == 'desc' ? :desc : :asc
    end

    def sort_sql(table_name)
      "#{sort_column(table_name)} #{sort_direction(table_name)}"
    end

    def filter(models)
      params[:filter] ||= {}
      @filter = {}

      @column_types.each do |attr, col_type|
        case col_type
        when :string
          unless params[:filter][attr].blank?
            @filter[attr] = params[:filter][attr].sub(/\%*\z/, '%')
            # filtered_models = models.where(models.first.class.arel_table[attr].matches(@filter[attr]).to_sql)
            # Use MetaWhere instead:
            models = models.where(attr.matches => @filter[attr])
          end
        when :boolean
          case params[:filter][attr]
          when 'yes'
            @filter[attr] = true
            models = models.where(attr => true)
          when 'no'
            @filter[attr] = false
            models = models.where(attr => false)
          end
        end
      end
      models
    end

    def sort(models, table_name)
      models.order(sort_sql(table_name))
    end

    def paginate(models)
      params[:per_page] ||= 25
      models.page(params[:page]).per(params[:per_page])
    end

end
