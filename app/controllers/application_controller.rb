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

    def render_ms_excel_2003_xml_for_download(models,
                                              attributes,
                                              column_types,
                                              column_headers,
                                              filename)
      send_data render_to_string(
          :template => 'shared/index',
          :locals   =>
              { :models         => models,
                :attributes     => attributes,
                :column_types   => column_types,
                :column_headers => column_headers}),
          :filename    => filename,
          :type        => "#{Mime::MS_EXCEL_2003_XML.to_s}; "\
                          "charset=utf-8",
          :disposition => 'inline'
    end

    def render_csv_for_download(models, attributes, column_headers, filename)
      send_data csv_from_collection(models, attributes, column_headers),
                :filename    => filename,
                :type        => "#{Mime::CSV.to_s}; charset=utf-8",
                :disposition => 'inline'
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

    def sort_column(html_table_id)
      params.deep_merge! :sort => { html_table_id => {} }

      klass = html_table_id_to_class(html_table_id)

      if (suggested_sort_column = params[:sort][html_table_id][:column]).blank?
        default_column = default_sort_column(html_table_id)
      elsif klass.column_names.include?(suggested_sort_column) ||
                klass.virtual_attribute_to_sql(suggested_sort_column)
        suggested_sort_column.intern
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
      klass = html_table_id_to_class(html_table_id)
      column = sort_column(html_table_id).to_s

      if klass.column_names.include?(column)
        column_or_sql_expression = column
      else
        column_or_sql_expression =
            klass.attribute_to_column_name_or_sql_expression(column)
      end

      "#{column_or_sql_expression} "\
      "#{sort_direction_sql(html_table_id)}"
    end

    def filter(models, html_table_id)
      params[:filter] ||= {}
      @filter = {}

      # return models

      klass = html_table_id_to_class(html_table_id)

      @attributes.each do |attr|
        if real_column = klass.column_names.include?(attr.to_s)
          column_sql = [ klass.table_name, attr.to_s ].join('.')
        else
          column_sql = klass.attribute_to_column_name_or_sql_expression(attr)
        end
        case @column_types[attr]
        when :string, :delegated_string, :virtual_string
          unless params[:filter][attr].blank?
            @filter[attr] = params[:filter][attr].sub(/\%*\z/, '%')
            models = models.where("#{column_sql} LIKE ?", @filter[attr])  # SQL
            # NOTE: did not wind a way to do this with MetaWhere or pure Arel.
          end
        when :boolean
          unless params[:filter][attr].blank?
            case params[:filter][attr]
            when 'yes'
              @filter[attr] = true
              models = models.where(attr => true)
            when 'no'
              @filter[attr] = false
              models = models.where(attr => false)
            end
          end
        when :delegated_boolean
          unless params[:filter][attr].blank?
            case params[:filter][attr]
            when 'yes'
              @filter[attr] = true
              models = models.where("#{column_sql} = ?", true)
            when 'no'
              @filter[attr] = false
              models = models.where("#{column_sql} = ?", false)
            end
          end
        when :virtual_boolean
          unless params[:filter][attr].blank?
            case params[:filter][attr]
            when 'yes'
              @filter[attr] = true
              models = models.where("#{column_sql}")
            when 'no'
              @filter[attr] = false
              models = models.where("NOT #{column_sql}")
            end
          end
        when :integer, :delegated_integer, :virtual_integer
          params[:filter][attr] ||= {}

          unless params[:filter][attr][:min].blank?
            @filter[attr] ||= {}
            @filter[attr][:min] = params[:filter][attr][:min].to_i
            models = models.where("#{column_sql} >= ?", @filter[attr][:min])
          end
          unless params[:filter][attr][:max].blank?
            @filter[attr] ||= {}
            @filter[attr][:max] = params[:filter][attr][:max].to_i

            models = models.where("#{column_sql} <= ?", @filter[attr][:max])
          end
        when :date, :delegated_date, :virtual_date
          params[:filter][attr] ||= {}

          unless params[:filter][attr][:from].blank?
            @filter[attr] ||= {}
            @filter[attr][:from] = params[:filter][attr][:from]
            models = models.where("#{column_sql} >= ?", @filter[attr][:from])
          end
          unless params[:filter][attr][:until].blank?
            @filter[attr] ||= {}
            @filter[attr][:until] = params[:filter][attr][:until]
            models = models.where("#{column_sql} <= ?", @filter[attr][:until])
          end
        end
      end
      models
    end

    def sort(models, html_table_id)
      models.order(sort_sql(html_table_id))
    end

    def paginate(models)
      params[:per_page] ||= 25
      models.page(params[:page]).per(params[:per_page])
    end

    def approximate_time
      @approximate_time ||= Time.now
    end

end
