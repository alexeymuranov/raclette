## encoding: UTF-8

class InstructorsController < ManagerController

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.delete(:query_type)
    params.delete(:commit)
    params.delete(:button)

    if @query_type == 'filter' && @submit_button == 'clear_button'
      params.delete(:filter)
    end

    case request.format
    when 'html'
      @attributes = [:ordered_full_name,
                     :email,
                     :employed_from]
    when 'xml', 'csv', 'ms_excel_2003_xml'
      @attributes = [:last_name,
                     :first_name,
                     :email,
                     :employed_from]
    end

    @column_types = Instructor.attribute_db_types
    @sql_for_attributes = Instructor.sql_for_attributes

    @instructors = Instructor.joins(:person).
      with_virtual_attributes(*@attributes, :formatted_email)

    # Filter:
    @instructors = Instructor.filter(@instructors, params[:filter], @attributes)
    @filtering_values = Instructor.last_filter_values

    # Sort:
    Instructor.all_sorting_columns = @attributes
    Instructor.default_sorting_column = ( request.format == 'html' ?
                                          :ordered_full_name : :last_name )
    sort_params = (params[:sort] && params[:sort][:instructors]) || {}
    @instructors = Instructor.sort(@instructors, sort_params)
    @sorting_column = Instructor.last_sort_column
    @sorting_direction = Instructor.last_sort_direction

    # Compose mailing list:
    if params[:list_email_addresses]
      @mailing_list_members = @instructors.select { |member| !member.email.blank? }
      @mailing_list = @mailing_list_members.collect(&:formatted_email).
        join(', ')
    end

    set_column_headers

    respond_to do |requested_format|
      requested_format.html do
        # Paginate:
        @instructors = paginate(@instructors)

        # @title = t('members.index.title')  # or: Instructor.model_name.human.pluralize
        render :index
      end

      requested_format.js do
        case @query_type
        when 'show_email_addresses', 'hide_email_addresses'
          render :update_email_list
        end
      end

      # For download:
      requested_format.xml do
        render :xml  => @instructors,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download\
            @instructors,
            @attributes,
            @column_headers,
            "#{Instructor.model_name.human.pluralize}"\
            " #{Time.now.in_time_zone.strftime('%Y-%m-%d %k_%M')}"\
            ".excel2003.xml"  # defined in ApplicationController
      end

      requested_format.csv do
        render_csv_for_download\
            @instructors,
            @attributes,
            @column_headers,
            "#{Instructor.model_name.human.pluralize}"\
            " #{Time.now.in_time_zone.strftime('%Y-%m-%d %k_%M')}"\
            ".csv"  # defined in ApplicationController
      end
    end
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

    def render_new_properly
      @column_types = Instructor.attribute_db_types

      @title = t('instructors.new.title')

      render :new
    end

    def render_edit_properly
      @column_types = Instructor.attribute_db_types

      @title =  t('instructors.edit.title', :name => @instructor.non_sql_full_name)

      render :edit
    end

    def set_column_headers
      @column_headers = {}
      @attributes.each do |attr|
        @column_headers[attr] = Instructor.human_attribute_name(attr)

        case @column_types[attr]
        when :boolean, :delegated_boolean, :virtual_boolean
          @column_headers[attr] = I18n.t('formats.attribute_name?',
              :attribute => @column_headers[attr])
        else
          @column_headers[attr] = I18n.t('formats.attribute_name:',
              :attribute => @column_headers[attr])
        end
      end
    end

end
