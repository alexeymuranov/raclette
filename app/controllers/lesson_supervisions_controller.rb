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

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]

    if @submit_button == 'clear'
      params.delete(:filter)
    end

    if  @submit_button == 'filter' || @submit_button == 'clear'
      params.delete(:page)
    end

    # FIXME: strange if this is necessary:
    params.except!(:query_type, :commit, :button)

    case request.format
    when Mime::HTML
      @attributes = [:unique_names, :instructors_count, :comment]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML, Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attributes = [:unique_names, :instructors_count, :comment]
    end

    @column_types = LessonSupervision.attribute_db_types

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

    @column_headers = LessonSupervision.human_column_headers

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

      requested_format.ms_excel_2003_xml_zip do
       send_ms_excel_2003_xml_zip_for_download @lesson_supervisions,
                                               @attributes,
                                               @column_headers
      end

      requested_format.csv_zip do
        send_csv_zip_for_download @lesson_supervisions,
                                  @attributes,
                                  @column_headers
      end
    end
  end

  def show
    @attributes = [:unique_names, :instructors_count, :comment]

    @lesson_supervision = LessonSupervision.find(params[:id])

    @column_types = LessonSupervision.attribute_db_types

    @instructors_attributes = [:first_name, :last_name, :email]
    @instructors = @lesson_supervision.instructors.default_order
    @instructors_column_types = Instructor.attribute_db_types
    @instructors_column_headers = Instructor.human_column_headers

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

end
