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

    @lesson_supervisions = LessonSupervision.all

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
    attributes = process_raw_lesson_supervision_attributes_for_create
    @lesson_supervision = LessonSupervision.new(attributes)

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

    attributes = process_raw_lesson_supervision_attributes_for_update

    if @lesson_supervision.update_attributes(attributes)
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
      @attribute_names = [:unique_names, :comment]

      @title = t('lesson_supervisions.new.title')

      render :new
    end

    def render_edit_properly
      @attribute_names = [:unique_names, :comment]

      @title = t('lesson_supervisions.edit.title',
                 :title => @lesson_supervision.unique_names)

      render :edit
    end

  module AttributesFromParamsForCreate
    LESSON_SUPERVISION_ATTRIBUTE_NAMES =
      Set[:instructor_ids, :unique_names, :comment]
    LESSON_SUPERVISION_ATTRIBUTE_NAMES_FROM_STRINGS =
      LESSON_SUPERVISION_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def lesson_supervision_attribute_name_from_params_key_for_create(params_key)
        LESSON_SUPERVISION_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_lesson_supervision_attributes_for_create(
            submitted_attributes = params['lesson_supervision'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [lesson_supervision_attribute_name_from_params_key_for_create(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          [attr_name, value == '' ? nil : value]
        }

        Hash[attributes_in_array].tap do |attributes|
          if attributes.key?(:instructor_ids)
            attributes[:instructor_ids] =
              process_raw_lesson_supervision_instructor_ids_for_create(
                attributes[:instructor_ids])
          end
        end
      end

      def process_raw_lesson_supervision_instructor_ids_for_create(
            submitted_ids = params['lesson_supervision']['instructor_ids'])
        submitted_ids.nil? ? [] : submitted_ids.map(&:to_i)
      end

  end
  include AttributesFromParamsForCreate

  module AttributesFromParamsForUpdate
    LESSON_SUPERVISION_ATTRIBUTE_NAMES = Set[:comment]
    LESSON_SUPERVISION_ATTRIBUTE_NAMES_FROM_STRINGS =
      LESSON_SUPERVISION_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def lesson_supervision_attribute_name_from_params_key_for_update(params_key)
        LESSON_SUPERVISION_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_lesson_supervision_attributes_for_update(
            submitted_attributes = params['lesson_supervision'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [lesson_supervision_attribute_name_from_params_key_for_update(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          [attr_name, value == '' ? nil : value]
        }
        Hash[attributes_in_array]
      end

  end
  include AttributesFromParamsForUpdate
end
