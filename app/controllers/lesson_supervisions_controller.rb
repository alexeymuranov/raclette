## encoding: UTF-8

class LessonSupervisionsController < SecretaryController

  def index
    case request.format
    when Mime::HTML
      @attribute_names = [:unique_names, :instructors_count, :comment]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attribute_names = [:unique_names, :instructors_count, :comment]
    end

    @lesson_supervisions = LessonSupervision.scoped

    # Filter:
    @lesson_supervisions = do_filtering(@lesson_supervisions)
    @filtered_lesson_supervisions_count = @lesson_supervisions.count

    # Sort:
    sort_params = (params[:sort] && params[:sort][:lesson_supervisions]) || {}
    @lesson_supervisions =
      sort(@lesson_supervisions, sort_params, :instructors_count)

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @lesson_supervisions = paginate(@lesson_supervisions)

        render :index
      end

      requested_format.xml do
        render :xml  => @lesson_supervisions,
               :only => @attribute_names
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @lesson_supervisions,
               :only                             => @attribute_names
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @lesson_supervisions,
               :only               => @attribute_names
      end
    end
  end

  def show
    @lesson_supervision = LessonSupervision.find(params['id'])

    @attribute_names = [:unique_names, :instructors_count, :comment]

    @instructor_attribute_names = [:first_name, :last_name, :email]
    @instructors = @lesson_supervision.instructors.default_order

    @title = t('lesson_supervisions.show.title',
               :title => @lesson_supervision.unique_names)
  end

  def new
    @lesson_supervision = LessonSupervision.new

    render_new_properly
  end

  def edit
    @lesson_supervision = LessonSupervision.find(params['id'])

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
    @lesson_supervision = LessonSupervision.find(params['id'])

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
    @lesson_supervision = LessonSupervision.find(params['id'])

    @lesson_supervision.destroy

    flash[:notice] = t('flash.lesson_supervisions.destroy.success',
                       :title => @lesson_supervision.unique_names)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      # @attribute_names = [:unique_names, :instructors_count, :comment]
      @attribute_names = [:unique_names, :comment]

      @title = t('lesson_supervisions.new.title')

      render :new
    end

    def render_edit_properly
      # @attribute_names = [:unique_names, :instructors_count, :comment]
      @attribute_names = [:unique_names, :comment]

      @title = t('lesson_supervisions.edit.title',
                 :title => @lesson_supervision.unique_names)

      render :edit
    end

end
