## encoding: UTF-8

class InstructorsController < ManagerController

  INSTRUCTOR_ATTRIBUTE_NAMES_FOR_HTML_INDEX = [ :ordered_full_name,
                                                :email,
                                                :employed_from ]
  INSTRUCTOR_ATTRIBUTE_NAMES_FOR_XML_INDEX  = [ :last_name,
                                                :first_name,
                                                :email,
                                                :employed_from ]
  def index
    case request.format
    when Mime::HTML
      @attribute_names = INSTRUCTOR_ATTRIBUTE_NAMES_FOR_HTML_INDEX
      default_sorting_column = :ordered_full_name
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attribute_names = INSTRUCTOR_ATTRIBUTE_NAMES_FOR_XML_INDEX
      default_sorting_column = :last_name
    end

    if selected_attribute_names = params['attribute_names']
      @attribute_names = @attribute_names.select { |attr|
        selected_attribute_names[attr.to_s] }
    end

    @instructors = Instructor.joins(:person).
      with_pseudo_columns(*@attribute_names, :formatted_email)

    # Filter:
    @instructors = do_filtering(@instructors)
    @filtered_instructors_count = @instructors.count

    # Sort:
    sort_params = (params['sort'] && params['sort']['instructors']) || {}
    @instructors = sort(@instructors, sort_params, default_sorting_column)

    # Compose mailing list:
    if params['list_email_addresses']
      @mailing_list_instructors =
        @instructors.select { |instructor| !instructor.email.blank? }
      @mailing_list =
        @mailing_list_instructors.collect(&:formatted_email).join(', ')
    end

    respond_to do |requested_format|
      requested_format.html do
        # Paginate:
        @instructors = paginate(@instructors)

        render :index
      end

      requested_format.js do
        case params['button']
        when 'show_email_addresses', 'hide_email_addresses'
          render :update_email_list
        end
      end

      # For download:
      requested_format.xml do
        render :xml  => @instructors,
               :only => @attribute_names
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @instructors,
               :only                             => @attribute_names
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @instructors,
               :only               => @attribute_names
      end
    end
  end

  INSTRUCTOR_ATTRIBUTE_NAMES_FOR_SHOW = [ :name_title,
                                          :first_name,
                                          :last_name,
                                          :nickname_or_other,
                                          :email,
                                          :employed_from ]
  def show
    @instructor = Instructor.find(params['id'])

    @attribute_names = INSTRUCTOR_ATTRIBUTE_NAMES_FOR_SHOW
    if selected_attribute_names = params['attribute_names']
      @attribute_names = @attribute_names.select { |attr|
        selected_attribute_names[attr.to_s] }
    end

    @title = t('instructors.show.title', :name => @instructor.virtual_full_name)
  end

  INSTRUCTOR_ATTRIBUTE_NAMES_FOR_NEW = [ :employed_from ]
  INSTRUCTOR_PERSON_ATTRIBUTE_NAMES_FOR_NEW = [ :name_title,
                                                :first_name,
                                                :last_name,
                                                :nickname_or_other,
                                                :email ]
  def new
    @attribute_names        = INSTRUCTOR_ATTRIBUTE_NAMES_FOR_NEW
    @person_attribute_names = INSTRUCTOR_PERSON_ATTRIBUTE_NAMES_FOR_NEW

    @instructor = Person.new.build_instructor

    render_new_properly
  end

  INSTRUCTOR_ATTRIBUTE_NAMES_FOR_EDIT = [ :employed_from ]
  INSTRUCTOR_PERSON_ATTRIBUTE_NAMES_FOR_EDIT = [ :name_title,
                                                 :first_name,
                                                 :last_name,
                                                 :nickname_or_other,
                                                 :email ]
  def edit
    @instructor = Instructor.find(params['id'])

    @attribute_names        = INSTRUCTOR_ATTRIBUTE_NAMES_FOR_EDIT
    @person_attribute_names = INSTRUCTOR_PERSON_ATTRIBUTE_NAMES_FOR_EDIT
    selected_attribute_names        = params['attribute_names']
    selected_person_attribute_names = params['person_attribute_names']
    if selected_attribute_names || selected_person_attribute_names
      selected_attribute_names        ||= []
      selected_person_attribute_names ||= []
      @attribute_names = @attribute_names.select { |attr|
        selected_attribute_names[attr.to_s] }
      @person_attribute_names = @person_attribute_names.select { |attr|
        selected_person_attribute_names[attr.to_s] }
    end

    render_edit_properly
  end

  def create
    # Because instructors primary key works as foreign key for people
    # (this is not recommended in general),
    # building an associated person and saving the instructor with person with
    # "@instructor.save" does not seem to work in rails 3.0.9
    # (probably causes stack overflow).
    # The only workaround seems to be to save the person first,
    # assign the foreign key manually, and then save the instructor.
    attributes =
      process_raw_instructor_attributes_for_create

    @person = Person.new(attributes.delete(:person_attributes))
    @instructor = Instructor.new(attributes)
    @instructor.person = @person

    unless @person.save
      flash.now[:error] = t('flash.instructors.create.failure')

      render_new_properly and return
    end

    if params['automatic_lesson_supervision'] == '1'
      # Create a default one-person lesson supervision.
      # NOTE: for some (or same) reason, @instructor.lesson_supervisions.build
      # does not work here.
      @instructor.lesson_supervisions <<
        LessonSupervision.new(
          :unique_names      => @instructor.virtual_professional_name,
          :instructors_count => 1)
    end

    if @instructor.save
      flash[:success] = t('flash.instructors.create.success',
                          :name => @instructor.virtual_full_name)
      redirect_to :action => :show,
                  :id     => @instructor.id
    else
      flash.now[:error] = t('flash.instructors.create.failure')

      render_new_properly
    end
  end

  def update
    @instructor = Instructor.find(params['id'])

    attributes =
      process_raw_instructor_attributes_for_update

    if @instructor.update_attributes(attributes)
      flash[:notice] = t('flash.instructors.update.success',
                         :name => @instructor.virtual_full_name)

      redirect_to :action => :show,
                  :id     => @instructor.id
    else
      flash.now[:error] = t('flash.instructors.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @instructor = Instructor.find(params['id'])

    if @instructor.person.associated_roles == [:instructor]
      @instructor.person.destroy
    else
      @instructor.destroy
    end

    flash[:notice] = t('flash.instructors.destroy.success',
                       :name => @instructor.virtual_full_name)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @title = t('instructors.new.title')

      render :new
    end

    def render_edit_properly
      @title = t('instructors.edit.title',
                 :name => @instructor.virtual_full_name)

      render :edit
    end

  module AttributesFromParamsForCreate
    INSTRUCTOR_ATTRIBUTE_NAMES = Set[ :employed_from ]
    INSTRUCTOR_PERSON_ATTRIBUTE_NAMES = Set[ :name_title,
                                             :first_name,
                                             :last_name,
                                             :nickname_or_other,
                                             :email ]
    INSTRUCTOR_ATTRIBUTE_NAMES_FROM_STRINGS =
      INSTRUCTOR_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }
    INSTRUCTOR_PERSON_ATTRIBUTE_NAMES_FROM_STRINGS =
      INSTRUCTOR_PERSON_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def instructor_attribute_name_from_params_key_for_create(params_key)
        INSTRUCTOR_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def instructor_person_attribute_name_from_params_key_for_create(params_key)
        INSTRUCTOR_PERSON_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_instructor_attributes_for_create(
            submitted_attributes = params['instructor'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [instructor_attribute_name_from_params_key_for_create(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          [attr_name, value == '' ? nil : value]
        }

        Hash[attributes_in_array].tap do |attributes|
          submitted_person_attributes =
            submitted_attributes['person_attributes']
          if submitted_person_attributes
            attributes[:person_attributes] =
              process_raw_instructor_person_attributes_for_create(
                submitted_person_attributes)
          end
        end
      end

      def process_raw_instructor_person_attributes_for_create(
            submitted_attributes = params['instructor']['person_attributes'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [instructor_person_attribute_name_from_params_key_for_create(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          [attr_name, value == '' ? nil : value]
        }

        Hash[attributes_in_array].tap do |attributes|
          if attributes.key?(:nickname_or_other)
            attributes[:nickname_or_other] ||= ''
          end
        end
      end

  end
  include AttributesFromParamsForCreate

  module AttributesFromParamsForUpdate
    INSTRUCTOR_ATTRIBUTE_NAMES =
      AttributesFromParamsForCreate::INSTRUCTOR_ATTRIBUTE_NAMES
    INSTRUCTOR_PERSON_ATTRIBUTE_NAMES =
      AttributesFromParamsForCreate::INSTRUCTOR_PERSON_ATTRIBUTE_NAMES | [:id]
    INSTRUCTOR_ATTRIBUTE_NAMES_FROM_STRINGS =
      INSTRUCTOR_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }
    INSTRUCTOR_PERSON_ATTRIBUTE_NAMES_FROM_STRINGS =
      INSTRUCTOR_PERSON_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def instructor_attribute_name_from_params_key_for_update(params_key)
        INSTRUCTOR_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def instructor_person_attribute_name_from_params_key_for_update(params_key)
        INSTRUCTOR_PERSON_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_instructor_attributes_for_update(
            submitted_attributes = params['instructor'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [instructor_attribute_name_from_params_key_for_update(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          [attr_name, value == '' ? nil : value]
        }

        Hash[attributes_in_array].tap do |attributes|
          submitted_person_attributes =
            submitted_attributes['person_attributes']
          if submitted_person_attributes
            attributes[:person_attributes] =
              process_raw_instructor_person_attributes_for_update(
                submitted_person_attributes)
          end
        end
      end

      def process_raw_instructor_person_attributes_for_update(
            submitted_attributes = params['instructor']['person_attributes'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [instructor_person_attribute_name_from_params_key_for_update(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          [attr_name, value == '' ? nil : value]
        }

        Hash[attributes_in_array].tap do |attributes|
          if attributes.key?(:nickname_or_other)
            attributes[:nickname_or_other] ||= ''
          end
        end
      end

  end
  include AttributesFromParamsForUpdate
end
