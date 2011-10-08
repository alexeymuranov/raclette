## encoding: UTF-8

require 'csv'  # to render CSV
require 'assets/app_sql_queries/simple_filter'

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

    def render_ms_excel_2003_xml_for_download(scoped_collection,
                                              attributes,
                                              column_headers,
                                              filename=nil)
      klass = scoped_collection.klass
      if klass.superclass == AbstractSmarterModel
        column_types = klass.attribute_db_types
      else
        column_types = {}
        attributes.each do |attr|
          column_types[attr] = klass.columns_hash[attr.to_s].type
        end
      end
      filename ||= "#{klass.model_name.human.pluralize}"\
                   " #{Time.now.in_time_zone.strftime('%Y-%m-%d %k_%M')}"\
                   ".excel2003.xml"
      send_data render_to_string(
          :template => 'shared/index',
          :locals   =>
              { :models         => scoped_collection,
                :attributes     => attributes,
                :column_types   => column_types,
                :column_headers => column_headers}),
          :filename     => filename,
          :content_type => "#{Mime::MS_EXCEL_2003_XML.to_s}; "\
                          "charset=utf-8",
          :disposition  => 'inline'
    end

    def render_csv_for_download(models, attributes, column_headers, filename)
      send_data csv_from_collection(models, attributes, column_headers),
                :filename     => filename,
                :content_type => "#{Mime::CSV.to_s}; charset=utf-8",
                :disposition  => 'inline'
    end

    def csv_from_collection(models, attributes, column_headers)
      CSV.generate(:col_sep       => ';',
                   :row_sep       => "\r\n",
                   :encoding      => 'utf-8') do |csv|
        csv << attributes.map { |attr| column_headers[attr] } << []
        models.each do |model|
          csv << attributes.map { |attr| model.public_send(attr).to_s }
        end
      end
    end

    def filter(scoped_collection)
      klass = scoped_collection.klass

      sfilter = SimpleFilter.new
      if params[:filter]
        sfilter.set_filtering_values_from_human_hash(params[:filter], klass)
        sfilter.filtering_attributes = @attributes
        scoped_collection = sfilter.do_filter(scoped_collection)
      end
      @filtering_values = sfilter.filtering_values
      scoped_collection
    end

    def sort_column(html_table_id)
      params.deep_merge! :sort => { html_table_id => {} }

      # does it make sence to replace with klass.default_sort_column ?
      # (would need to define default_sort_column in calsses)
      default_column = default_sort_column(html_table_id)

      if (suggested_sort_column = params[:sort][html_table_id][:column]).blank?
        default_column
      elsif @attributes.map(&:to_s).include?(suggested_sort_column)
        suggested_sort_column.to_sym
      else
        default_column
      end
    end

    def sort_direction(html_table_id)
      params.deep_merge! :sort => { html_table_id => {} }

      params[:sort][html_table_id][:direction] == 'desc' ? :desc : :asc
    end

    def sort_direction_sql(html_table_id)
      sort_direction(html_table_id).to_s.upcase
    end

    def sort_sql(html_table_id)
      "#{sort_column(html_table_id).to_s} "\
      "#{sort_direction_sql(html_table_id)}"
    end

    def sort(scoped_collection, html_table_id)
      scoped_collection.order(sort_sql(html_table_id))
    end

    def paginate(models)
      if params[:per_page].to_i > 1000
         params[:per_page] = 1000
      else
        params[:per_page] ||= 25
      end
      models.page(params[:page]).per(params[:per_page])
    end

    def approximate_time
      @approximate_time ||= Time.now
    end

end
