## encoding: UTF-8

class InstructorsController < ManagerController

  def index
    case request.format
    when Mime::HTML
      @attribute_names = [ :ordered_full_name,
                           :email,
                           :employed_from ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attribute_names = [ :last_name,
                           :first_name,
                           :email,
                           :employed_from ]
    end

    @instructors = Instructor.joins(:person).
      with_pseudo_columns(*@attribute_names, :formatted_email)

    # Filter:
    @instructors = do_filtering(@instructors)
    @filtered_instructors_count = @instructors.count

    # Sort:
    default_sorting_column =
      request.format == 'html' ? :ordered_full_name : :last_name
    sort_params = (params[:sort] && params[:sort][:instructors]) || {}
    @instructors = sort(@instructors, sort_params, default_sorting_column)

    # Compose mailing list:
    if params[:list_email_addresses]
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
        case params[:button]
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

  def show
    @instructor = Instructor.find(params['id'])

    @attribute_names = [ :name_title,
                         :first_name,
                         :last_name,
                         :nickname_or_other,
                         :email,
                         :employed_from ]

    @title = t('instructors.show.title', :name => @instructor.virtual_full_name)
  end

  def new
    @instructor = Instructor.new
    @instructor.build_person

    render_new_properly
  end

  def edit
    @instructor = Instructor.find(params['id'])

    render_edit_properly
  end

  def create
    params['instructor']['person_attributes'].tap { |h|
      h.each_pair do |k, v| h[k] = nil if v.blank? end
      h['nickname_or_other'] ||= ''
    }
    params['instructor'].tap { |h|
      h.each_pair do |k, v| h[k] = nil if v.blank? end
    }

    # Because instructors primary key works as foreign key for people
    # (this is not recommended in general),
    # building an associated person and saving the instructor with person with
    # "@instructor.save" does not seem to work in rails 3.0.9
    # (probably causes stack overflow).
    # The only workaround seems to be to save the person first,
    # assign the foreign key manually, and then save the instructor.
    @person = Person.new(params[:instructor][:person_attributes])
    @instructor = Instructor.new(params[:instructor].except(:person_attributes))
    @instructor.person = @person

    unless @person.save
      flash.now[:error] = t('flash.instructors.create.failure')

      render_new_properly and return
    end

    if params[:automatic_lesson_supervision] == '1'
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

    params['instructor']['person_attributes'].tap { |h|
      h.each_pair do |k, v| h[k] = nil if v.blank? end
      h['nickname_or_other'] ||= ''
    }
    params['instructor'].tap { |h|
      h.each_pair do |k, v| h[k] = nil if v.blank? end
    }

    if @instructor.update_attributes(params[:instructor])
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

end
