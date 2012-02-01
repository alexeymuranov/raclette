## encoding: UTF-8

require 'set'  # to be able to use Set
require 'csv'  # to render CSV
require 'assets/app_sql_queries/simple_filter'
require 'monkey_patches/action_controller'

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
