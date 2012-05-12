## encoding: UTF-8

class LessonSupervisionsController < SecretaryController

  class LessonSupervision < LessonSupervision
    has_many :instructors, :through    => :lesson_instructors,
                           :class_name => :Instructor

    self.all_sorting_columns = [:unique_names, :instructors_count]
    self.default_sorting_column = :instructors_count
  end

  class Instructor < Instructor
    self.all_sorting_columns = [ :ordered_full_name,
                                 :first_name,
                                 :last_name,
                                 :email,
                                 :employed_from ]
    self.default_sorting_column = :first_name
  end

  # param_accessible /.+/

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.except!(:query_type, :commit, :button)

    if @submit_button == 'clear_button'
      params.delete(:filter)
    end

    case request.format
    when Mime::HTML
      @attributes = [:unique_names, :instructors_count, :comment]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML
      @attributes = [:unique_names, :instructors_count, :comment]
    end

    set_column_types

    @lesson_supervisions = LessonSupervision.scoped

    # Filter:
    @lesson_supervisions = LessonSupervision.filter(@lesson_supervisions,
                                                    params[:filter],
                                                    @attributes)
    @filtering_values = LessonSupervision.last_filter_values
    @filtered_lesson_supervisions_count = @lesson_supervisions.count

    # Sort:
    LessonSupervision.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:lesson_supervisions]) || {}
    @lesson_supervisions =
      LessonSupervision.sort(@lesson_supervisions, sort_params)
    @sorting_column = LessonSupervision.last_sort_column
    @sorting_direction = LessonSupervision.last_sort_direction

    set_column_headers

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @lesson_supervisions = paginate(@lesson_supervisions)

        # @title = t('lesson_supervisions.index.title')  # or: LessonSupervision.model_name.human.pluralize
        render :index
      end

      requested_format.xml do
        render :xml  => @lesson_supervisions,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download @lesson_supervisions,
                                              @attributes,
                                              @column_headers
      end

      requested_format.csv do
        render_csv_for_download @lesson_supervisions,
                                @attributes,
                                @column_headers
      end
    end
  end

  def show
    @attributes = [:unique_names, :instructors_count, :comment]

    @lesson_supervision = LessonSupervision.find(params[:id])

    @column_types = LessonSupervision.attribute_db_types
    # set_column_headers

    @instructors_attributes = [:first_name, :last_name, :email]
    @instructors = @lesson_supervision.instructors.default_order
    @instructors_column_types = Instructor.attribute_db_types
    set_instructors_column_headers

    @title = t('lesson_supervisions.show.title',
               :title => @lesson_supervision.unique_names)
  end

  def new
    @lesson_supervision = LessonSupervision.new

    render_new_properly
  end

  def edit
    @lesson_supervision = LessonSupervision.find(params[:id])

    render_edit_properly
  end

  def create
    @lesson_supervision = LessonSupervision.new(params[:lesson_supervision])

    if @lesson_supervision.save
      # XXX: temporary workaround to override 'counter cache':
      @lesson_supervision.instructors_count =
        @lesson_supervision.instructors.count
      @lesson_supervision.save

      flash[:success] = t('flash.lesson_supervisions.create.success',
                          :title => @lesson_supervision.unique_names)
      redirect_to :action => :show,
                  :id     => @lesson_supervision
    else
      flash.now[:error] = t('flash.lesson_supervisions.create.failure')

      render_new_properly
    end
  end

  def update
    @lesson_supervision = LessonSupervision.find(params[:id])

    if @lesson_supervision.update_attributes(params[:lesson_supervision])
      flash[:notice] = t('flash.lesson_supervisions.update.success',
                         :title => @lesson_supervision.unique_names)
      redirect_to :action => :show,
                  :id     => @lesson_supervision
    else
      flash.now[:error] = t('flash.lesson_supervisions.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @lesson_supervision = LessonSupervision.find(params[:id])
    @lesson_supervision.destroy

    flash[:notice] = t('flash.lesson_supervisions.destroy.success',
                       :title => @lesson_supervision.unique_names)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      # @attributes = [:unique_names, :instructors_count, :comment]
      @attributes = [:unique_names, :comment]
      @column_types = LessonSupervision.attribute_db_types

      @title = t('lesson_supervisions.new.title')

      render :new
    end

    def render_edit_properly
      # @attributes = [:unique_names, :instructors_count, :comment]
      @attributes = [:unique_names, :comment]
      @column_types = LessonSupervision.attribute_db_types

      @title =  t('lesson_supervisions.edit.title',
                  :title => @lesson_supervision.unique_names)

      render :edit
    end

    def set_column_types
      @column_types = {}
      LessonSupervision.columns_hash.each do |key, value|
        @column_types[key.to_sym] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = LessonSupervision.human_attribute_name(attr)

        case type
        when :boolean
          @column_headers[attr] = I18n.t('formats.attribute_name?',
                                         :attribute => human_name)
        else
          @column_headers[attr] = I18n.t('formats.attribute_name:',
                                         :attribute => human_name)
        end
      end
    end

    def set_instructors_column_headers
      @instructors_column_headers = {}
      @instructors_column_types.each do |attr, type|
        human_name = Instructor.human_attribute_name(attr)

        case type
        when :boolean
          @instructors_column_headers[attr] = I18n.t('formats.attribute_name?',
                                                     :attribute => human_name)
        else
          @instructors_column_headers[attr] = I18n.t('formats.attribute_name:',
                                                     :attribute => human_name)
        end
      end
    end

end
