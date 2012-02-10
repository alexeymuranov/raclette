## encoding: UTF-8

require 'set'  # to be able to use Set
require 'csv'  # to render CSV
require 'monkey_patches/action_controller'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper
  include SessionsHelper

  before_filter :require_login
  before_filter :set_locale

  ActionController.add_renderer :csv do |obj, options| # FIXME:WIP
    # filename = options[:filename] || 'data'
    # str = obj.respond_to?(:to_csv) ? obj.to_csv : obj.to_s
    # send_data str, :type => Mime::CSV,
    #   :disposition => "attachment; filename=#{filename}.csv"
    self.content_type ||= Mime::CSV
    klass = obj.klass
    csv = csv_from_collection(obj, options[:attributes],
                                   options[:column_headers])
    filename = options[:filename] || "#{klass.model_name.human.pluralize}"\
      " #{Time.now.in_time_zone.strftime('%Y-%m-%d %k_%M')}.csv"
    self.response_body = csv
    send_data csv, :filename     => filename,
                   :content_type => "#{Mime::CSV}; charset=utf-8",
                   :disposition  => 'inline'
  end

  ActionController.add_renderer :ms_excel_2003_xml do |obj, options| # FIXME:WIP
    self.content_type ||= Mime::MS_EXCEL_2003_XML
    klass = obj.klass
    if obj.is_a?(AbstractSmarterModel)
      column_types = klass.attribute_db_types
    else
      column_types = {}
      attributes.each do |attr|
        column_types[attr] = klass.columns_hash[attr.to_s].type
      end
    end
    ms_excel_2003_xml = render_to_string(
      :template    => 'shared/index',
      :locals      => { :models         => obj,
                        :attributes     => options[:attributes],
                        :column_types   => column_types,
                        :column_headers => options[:column_headers] })
    filename = options[:filename] || "#{klass.model_name.human.pluralize}"\
      " #{Time.now.in_time_zone.strftime('%Y-%m-%d %k_%M')}.excel2003.xml"
    send_data ms_excel_2003_xml,
              :filename     => filename,
              :content_type => "#{Mime::MS_EXCEL_2003_XML}; charset=utf-8",
              :disposition  => 'inline'
  end

  private

    def set_locale  # before_filter
      # if params[:locale] is nil, then I18n.default_locale will be used
      I18n.locale = params[:locale]
      @locale = I18n.locale
    end

    def render_ms_excel_2003_xml_for_download(scoped_collection,
                                              attributes,
                                              column_headers,
                                              filename=nil)
      klass = scoped_collection.klass
      if scoped_collection.is_a?(AbstractSmarterModel)
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
                :column_headers => column_headers }),
          :filename     => filename,
          :content_type => "#{Mime::MS_EXCEL_2003_XML}; charset=utf-8",
          :disposition  => 'inline'
    end

    def render_csv_for_download(models, attributes, column_headers, filename)
      send_data csv_from_collection(models, attributes, column_headers),
                :filename     => filename,
                :content_type => "#{Mime::CSV}; charset=utf-8",
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

    def paginate(models, options={})
      per_page = options[:per_page] || params[:per_page]
      per_page = per_page ? per_page.to_i : 25
      per_page = 1000 if per_page.to_i > 1000
      page = options[:page] || params[:page]
      page = page ? page.to_i : 1
      models.page(page).per(per_page)
    end

    def approximate_time
      @approximate_time ||= Time.now
    end

end
