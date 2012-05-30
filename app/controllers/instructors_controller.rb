## encoding: UTF-8

class InstructorsController < ManagerController

  class Instructor < Instructor
    self.all_sorting_columns = [ :ordered_full_name,
                                 :email,
                                 :employed_from ]
    self.default_sorting_column = :ordered_full_name
  end

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.delete(:query_type)
    params.delete(:commit)
    params.delete(:button)

    params.delete(:filter) if @submit_button == 'clear_button'

    case request.format
    when Mime::HTML
      @attributes = [ :ordered_full_name,
                      :email,
                      :employed_from ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML
      @attributes = [ :last_name,
                      :first_name,
                      :email,
                      :employed_from ]
    end

    @column_types = Instructor.attribute_db_types
    @sql_for_attributes = Instructor.sql_for_attributes

    @instructors = Instructor.joins(:person).
      with_virtual_attributes(*@attributes, :formatted_email)

    # Filter:
    @instructors = Instructor.filter(@instructors, params[:filter], @attributes)
    @filtering_values = Instructor.last_filter_values
    @filtered_instructors_count = @instructors.count

    # Sort:
    Instructor.all_sorting_columns = @attributes
    Instructor.default_sorting_column =
      request.format == 'html' ? :ordered_full_name : :last_name
    sort_params = (params[:sort] && params[:sort][:instructors]) || {}
    @instructors = Instructor.sort(@instructors, sort_params)
    @sorting_column = Instructor.last_sort_column
    @sorting_direction = Instructor.last_sort_direction

    # Compose mailing list:
    if params[:list_email_addresses]
      @mailing_list_instructors =
        @instructors.select { |instructor| !instructor.email.blank? }
      @mailing_list =
        @mailing_list_instructors.collect(&:formatted_email).join(', ')
    end

    set_column_headers

    respond_to do |requested_format|
      requested_format.html do
        # Paginate:
        @instructors = paginate(@instructors)

        # @title = t('instructors.index.title')  # or: Instructor.model_name.human.pluralize
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
        render_ms_excel_2003_xml_for_download @instructors,
                                              @attributes,
                                              @column_headers
      end

      requested_format.csv do
        render_csv_for_download @instructors,
                                @attributes,
                                @column_headers
      end
    end
  end

  def show
    @attributes = [ :name_title,
                    :first_name,
                    :last_name,
                    :nickname_or_other,
                    :email,
                    :full_name,
                    :employed_from ]

    @instructor =
      Instructor.joins(:person).with_virtual_attributes(*@attributes).
                 find(params[:id])

    @column_types = Instructor.attribute_db_types
    # set_column_headers

    @title = t('instructors.show.title', :name => @instructor.non_sql_full_name)
  end

  def new
    @instructor = Instructor.new
    @instructor.build_person

    render_new_properly
  end

  def edit
    @instructor =
      Instructor.joins(:person).with_virtual_attributes(:full_name).
                 find(params[:id])
    render_edit_properly
  end

  def create

    params[:instructor].delete(:email) if params[:instructor][:email].blank?

    # Because instructors primary key works as foreign key for people
    # (this is not recommended in general),
    # building an associated person and saving the instructor with person with
    # "@instructor.save" does not seem to work in rails 3.0.9
    # (probably causes stack overflow).
    # The only workaround seems to be to save the person first,
    # assign the foreign key manually, and then save the instructor.
    @person = Person.new
    @instructor = Instructor.new
    params[:instructor][:person_attributes].delete(:email) if
      params[:instructor][:person_attributes][:email].blank?

    @person.assign_attributes(params[:instructor][:person_attributes])
    @instructor.assign_attributes(
      params[:instructor].except(:person_attributes))

    unless @person.save
      flash.now[:error] = t('flash.instructors.create.failure')
      @instructor.person = @person  # seems safe here

      render_new_properly and return
    end

    @instructor.person_id = @person.id

    # Create a default one-person lesson supervision:
    @lesson_supervision = LessonSupervision.create(
      :unique_names      => @instructor.non_sql_professional_name,
      :instructors_count => 1)
    @instructor.lesson_supervisions << @lesson_supervision

    if @instructor.save
      flash[:success] = t('flash.instructors.create.success',
                          :name => @instructor.non_sql_full_name)
      redirect_to :action => :show,
                  :id     => @instructor.id
    else
      flash.now[:error] = t('flash.instructors.create.failure')

      render_new_properly
    end
  end

  def update
    @instructor =
      Instructor.joins(:person).with_virtual_attributes(:full_name).
                 find(params[:id])

    params[:instructor][:person_attributes].delete(:email) if
      params[:instructor][:person_attributes][:email].blank?

    if @instructor.update_attributes(params[:instructor])
      flash[:notice] = t('flash.instructors.update.success',
                         :name => @instructor.full_name)

      redirect_to :action => :show,
                  :id     => @instructor.id
    else
      flash.now[:error] = t('flash.instructors.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @instructor = Instructor.find(params[:id])
    @instructor.destroy

    flash[:notice] = t('flash.instructors.destroy.success',
                       :name => @instructor.non_sql_full_name)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @column_types = Instructor.attribute_db_types

      @title = t('instructors.new.title')

      render :new
    end

    def render_edit_properly
      @column_types = Instructor.attribute_db_types

      @title =  t('instructors.edit.title',
                  :name => @instructor.non_sql_full_name)

      render :edit
    end

    def set_column_headers
      @column_headers = {}
      @attributes.each do |attr|
        @column_headers[attr] = Instructor.human_attribute_name(attr)

        case @column_types[attr]
        when :boolean
          @column_headers[attr] = I18n.t('formats.attribute_name?',
              :attribute => @column_headers[attr])
        else
          @column_headers[attr] = I18n.t('formats.attribute_name:',
              :attribute => @column_headers[attr])
        end
      end
    end

end
