## encoding: UTF-8

# NOTE: This controller is used to test changes before applying them to
# all controllers.

class MembersController < SecretaryController

  MEMBER_ATTRIBUTE_NAMES_FOR_HTML_INDEX = [ :ordered_full_name,
                                            :email,
                                            :account_deactivated,
                                            :tickets_count ]
  MEMBER_ATTRIBUTE_NAMES_FOR_XML_INDEX  = [ :last_name,
                                            :first_name,
                                            :nickname_or_other,
                                            :email,
                                            :tickets_count ]
  def index
    case request.format
    when Mime::HTML
      @attribute_names = MEMBER_ATTRIBUTE_NAMES_FOR_HTML_INDEX
      default_sorting_column = :ordered_full_name
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attribute_names = MEMBER_ATTRIBUTE_NAMES_FOR_XML_INDEX
      default_sorting_column = :last_name
    end

    if selected_attribute_names = params['attribute_names']
      @attribute_names = @attribute_names.select { |attr|
        selected_attribute_names[attr.to_s] }
    end

    @members = Member.joins(:person).
      with_pseudo_columns(*@attribute_names, :formatted_email)

    # Filter:
    @members = do_filtering(@members)
    @filtered_members_count = @members.count

    # Sort:
    sort_params = (params['sort'] && params['sort']['members']) || {}
    @members = sort(@members, sort_params, default_sorting_column)

    # Compose mailing list:
    if params['list_email_addresses']
      @mailing_list_members =
        @members.select { |member| !member.email.blank? }
      @mailing_list =
        @mailing_list_members.collect(&:formatted_email).join(', ')
    end

    respond_to do |requested_format|
      requested_format.html do
        # Paginate:
        @members = paginate(@members)

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
        render :xml  => @members,
               :only => @attribute_names
      end

      requested_format.ms_excel_2003_xml do
        render :collection_ms_excel_2003_xml => @members,
               :only                         => @attribute_names
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @members,
               :only                             => @attribute_names
      end

      requested_format.csv do
        render :collection_csv => @members,
               :only           => @attribute_names
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @members,
               :only               => @attribute_names
      end
    end
  end

  MEMBER_ATTRIBUTE_NAMES_FOR_SHOW = [ :person_id,
                                      :name_title,
                                      :first_name,
                                      :last_name,
                                      :nickname_or_other,
                                      :email,
                                      :payed_tickets_count,
                                      :free_tickets_count,
                                      :account_deactivated,
                                      :been_member_by ]
  def show
    @member = Member.find(params['id'])

    @attribute_names = MEMBER_ATTRIBUTE_NAMES_FOR_SHOW
    if selected_attribute_names = params['attribute_names']
      @attribute_names = @attribute_names.select { |attr|
        selected_attribute_names[attr.to_s] }
    end

    @attended_event_attribute_names = [:title, :event_type, :date, :start_time]
    @attended_events = @member.attended_events

    @membership_attribute_names = [:title, :duration_months, :end_date]
    @memberships = @member.memberships.with_type.with_activity_period.
      with_pseudo_columns(*@membership_attribute_names)

    @title = t('members.show.title', :name => @member.virtual_full_name)
  end

  MEMBER_ATTRIBUTE_NAMES_FOR_NEW = [ :payed_tickets_count,
                                     :free_tickets_count,
                                     :account_deactivated,
                                     :been_member_by ]
  MEMBER_PERSON_ATTRIBUTE_NAMES_FOR_NEW = [ :name_title,
                                            :first_name,
                                            :last_name,
                                            :nickname_or_other,
                                            :email ]
  def new
    @attribute_names        = MEMBER_ATTRIBUTE_NAMES_FOR_NEW
    @person_attribute_names = MEMBER_PERSON_ATTRIBUTE_NAMES_FOR_NEW

    @member = Person.new.build_member

    render_new_properly
  end

  MEMBER_ATTRIBUTE_NAMES_FOR_EDIT = [ :payed_tickets_count,
                                      :free_tickets_count,
                                      :account_deactivated,
                                      :been_member_by ]
  MEMBER_PERSON_ATTRIBUTE_NAMES_FOR_EDIT = [ :name_title,
                                             :first_name,
                                             :last_name,
                                             :nickname_or_other,
                                             :email ]
  def edit
    @member = Member.find(params['id'])

    @attribute_names        = MEMBER_ATTRIBUTE_NAMES_FOR_EDIT
    @person_attribute_names = MEMBER_PERSON_ATTRIBUTE_NAMES_FOR_EDIT
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
    # Because members primary key works as foreign key for people
    # (this is not recommended in general),
    # building an associated person and saving the member with person with
    # "@member.save" does not seem to work in rails 3.0.9
    # (probably causes stack overflow).
    # The only workaround seems to be to save the person first,
    # assign the foreign key manually, and then save the member.
    attributes = process_raw_member_attributes_for_create

    @person = Person.new(attributes.delete(:person_attributes))
    @member = Member.new(attributes)
    @member.person = @person

    unless @person.save
      flash.now[:error] = t('flash.members.create.failure')

      render_new_properly and return
    end

    if @member.save
      flash[:success] = t('flash.members.create.success',
                          :name => @member.virtual_full_name)
      redirect_to :action => :show,
                  :id     => @member
    else
      flash.now[:error] = t('flash.members.create.failure')

      render_new_properly
    end
  end

  def update
    @member = Member.find(params['id'])

    attributes = process_raw_member_attributes_for_update

    if @member.update_attributes(attributes)
      flash[:notice] = t('flash.members.update.success',
                         :name => @member.virtual_full_name)

      redirect_to :action => :show,
                  :id     => @member
    else
      flash.now[:error] = t('flash.members.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @member = Member.find(params['id'])

    if @member.person.associated_roles == [:member]
      @member.person.destroy
    else
      @member.destroy
    end

    flash[:notice] = t('flash.members.destroy.success',
                       :name => @member.virtual_full_name)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @title = t('members.new.title')

      render :new
    end

    def render_edit_properly
      @title = t('members.edit.title', :name => @member.virtual_full_name)

      render :edit
    end

  module AttributesFromParamsForCreate
    MEMBER_ATTRIBUTE_NAMES = Set[ :payed_tickets_count,
                                  :free_tickets_count,
                                  :account_deactivated,
                                  :been_member_by ]
    MEMBER_PERSON_ATTRIBUTE_NAMES = Set[ :name_title,
                                         :first_name,
                                         :last_name,
                                         :nickname_or_other,
                                         :email ]
    MEMBER_ATTRIBUTE_NAMES_FROM_STRINGS = {}.tap do |h|
      MEMBER_ATTRIBUTE_NAMES.each do |attr_name|
        h[attr_name.to_s] = attr_name
      end
    end
    MEMBER_PERSON_ATTRIBUTE_NAMES_FROM_STRINGS = {}.tap do |h|
      MEMBER_PERSON_ATTRIBUTE_NAMES.each do |attr_name|
        h[attr_name.to_s] = attr_name
      end
    end

    private

      def member_attribute_names_for_create
        MEMBER_ATTRIBUTE_NAMES
      end

      def member_person_attribute_names_for_create
        MEMBER_PERSON_ATTRIBUTE_NAMES
      end

      def process_raw_member_attributes_for_create(submitted_attributes = params['member'])
        allowed_attribute_names = member_attribute_names_for_create
        {}.tap do |attributes|
          submitted_attributes.each_pair do |k, v|
            attr_name = MEMBER_ATTRIBUTE_NAMES_FROM_STRINGS[k]
            if allowed_attribute_names.include?(attr_name)
              attributes[attr_name] = v == '' ? nil : v
            end
          end
          if submitted_attributes.key?('person_attributes')
            attributes[:person_attributes] =
              process_raw_member_person_attributes_for_create(
                submitted_attributes['person_attributes'])
          end
        end
      end

      def process_raw_member_person_attributes_for_create(submitted_attributes = params['member']['person_attributes'])
        allowed_attribute_names = member_person_attribute_names_for_create
        {}.tap do |attributes|
          submitted_attributes.each_pair do |k, v|
            attr_name = MEMBER_PERSON_ATTRIBUTE_NAMES_FROM_STRINGS[k]
            if allowed_attribute_names.include?(attr_name)
              attributes[attr_name] = v == '' ? nil : v
            end
          end
          if attributes.key?(:nickname_or_other)
            attributes[:nickname_or_other] ||= ''
          end
        end
      end

  end
  include AttributesFromParamsForCreate

  module AttributesFromParamsForUpdate
    MEMBER_ATTRIBUTE_NAMES =
      AttributesFromParamsForCreate::MEMBER_ATTRIBUTE_NAMES
    MEMBER_PERSON_ATTRIBUTE_NAMES = Set[ :id,
                                         :name_title,
                                         :first_name,
                                         :last_name,
                                         :nickname_or_other,
                                         :email ]
    MEMBER_ATTRIBUTE_NAMES_FROM_STRINGS = {}.tap do |h|
      MEMBER_ATTRIBUTE_NAMES.each do |attr_name|
        h[attr_name.to_s] = attr_name
      end
    end
    MEMBER_PERSON_ATTRIBUTE_NAMES_FROM_STRINGS = {}.tap do |h|
      MEMBER_PERSON_ATTRIBUTE_NAMES.each do |attr_name|
        h[attr_name.to_s] = attr_name
      end
    end

    private

      def member_attribute_names_for_update
        MEMBER_ATTRIBUTE_NAMES
      end

      def member_person_attribute_names_for_update
        MEMBER_PERSON_ATTRIBUTE_NAMES
      end

      def process_raw_member_attributes_for_update(submitted_attributes = params['member'])
        allowed_attribute_names = member_attribute_names_for_update
        {}.tap do |attributes|
          submitted_attributes.each_pair do |k, v|
            attr_name = MEMBER_ATTRIBUTE_NAMES_FROM_STRINGS[k]
            if allowed_attribute_names.include?(attr_name)
              attributes[attr_name] = v == '' ? nil : v
            end
          end
          if submitted_attributes.key?('person_attributes')
            attributes[:person_attributes] =
              process_raw_member_person_attributes_for_update(
                submitted_attributes['person_attributes'])
          end
        end
      end

      def process_raw_member_person_attributes_for_update(submitted_attributes = params['member']['person_attributes'])
        allowed_attribute_names = member_person_attribute_names_for_update
        {}.tap do |attributes|
          submitted_attributes.each_pair do |k, v|
            attr_name = MEMBER_PERSON_ATTRIBUTE_NAMES_FROM_STRINGS[k]
            if allowed_attribute_names.include?(attr_name)
              attributes[attr_name] = v == '' ? nil : v
            end
          end
          if attributes.key?(:nickname_or_other)
            attributes[:nickname_or_other] ||= ''
          end
        end
      end

  end
  include AttributesFromParamsForUpdate
end
