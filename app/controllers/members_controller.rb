## encoding: UTF-8

class MembersController < SecretaryController

  class Member < Member
    has_many :attended_events, :through    => :event_entries,
                               :source     => :event,
                               :class_name => :Event

    has_many :memberships, :through    => :member_memberships,
                           :class_name => :Membership

    self.all_sorting_columns = [ :ordered_full_name,
                                 :email,
                                 :account_deactivated,
                                 :tickets_count ]
    self.default_sorting_column = :ordered_full_name
  end

  class Membership < Membership
  end

  class Event < Event
    self.all_sorting_columns = [ :title, :event_type,
                                 :date,
                                 :start_time ]
    self.default_sorting_column = :date
  end

  class MembershipType < MembershipType
    self.all_sorting_columns = [ :username,
                                 :full_name,
                                 :account_deactivated,
                                 :admin,
                                 :manager,
                                 :secretary,
                                 :a_person ]
    self.default_sorting_column = :username
  end

  class ActivityPeriod < self::ActivityPeriod
    self.all_sorting_columns = [:ip, :description]
    self.default_sorting_column = :ip
  end

  param_accessible /.+/
  # param_accessible [{ 'member' => [ 'person_attributes',
  #                                   'last_name', 'first_name', 'name_title',
  #                                   'nickname_or_other', 'email',
  #                                   'free_tickets_count',
  #                                   'account_deactivated'] }],
  #                  :only => [:create, :update]
  # param_accessible [{ 'member' => 'been_member_by' }],
  #                  :only => :create

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.delete(:query_type)
    params.delete(:commit)
    params.delete(:button)

    if @submit_button == 'clear_button'
      params.delete(:filter)
    end

    case request.format
    when Mime::HTML
      @attributes = [ :ordered_full_name,
                      :email,
                      :account_deactivated,
                      :tickets_count ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML
      @attributes = [ :last_name,
                      :first_name,
                      :nickname_or_other,
                      :email,
                      :tickets_count ]
    end

    @column_types = Member.attribute_db_types
    @sql_for_attributes = Member.sql_for_attributes

    @members = Member.joins(:person).
      with_virtual_attributes(*@attributes, :formatted_email)

    # Filter:
    @members = Member.filter(@members, params[:filter], @attributes)
    @filtering_values = Member.last_filter_values
    @filtered_members_count = @members.count

    # Sort:
    Member.all_sorting_columns = @attributes
    Member.default_sorting_column = ( request.format == 'html' ?
                                      :ordered_full_name : :last_name )
    sort_params = (params[:sort] && params[:sort][:members]) || {}
    @members = Member.sort(@members, sort_params)
    @sorting_column = Member.last_sort_column
    @sorting_direction = Member.last_sort_direction

    # Compose mailing list:
    if params[:list_email_addresses]
      @mailing_list_members = @members.select { |member| !member.email.blank? }
      @mailing_list = @mailing_list_members.collect(&:formatted_email).
        join(', ')
    end

    set_column_headers unless request.format == Mime::JS

    respond_to do |requested_format|
      requested_format.html do
        # Paginate:
        @members = paginate(@members)

        # @title = t('members.index.title')  # or: Member.model_name.human.pluralize
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
        render :xml  => @members,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download @members,
                                              @attributes,
                                              @column_headers
      end

      requested_format.csv do
        render_csv_for_download @members,
                                @attributes,
                                @column_headers
      end
    end
  end

  def show
    @attributes = [ :person_id,
                    :name_title,
                    :first_name,
                    :last_name,
                    :nickname_or_other,
                    :email,
                    :payed_tickets_count,
                    :free_tickets_count,
                    :account_deactivated,
                    :been_member_by ]
    @extra_attributes = [:full_name]

    @member = Member.joins(:person).
                     with_virtual_attributes(*@attributes, *@extra_attributes).
                     find(params[:id])

    @column_types = Member.attribute_db_types
    # set_column_headers

    @attended_events_attributes = [ :title, :event_type, :date, :start_time ]
    @attended_events = @member.attended_events
    @events_column_types = Event.attribute_db_types
    set_events_column_headers

    @memberships_attributes = [:title, :duration_months, :end_date]
    @memberships = @member.memberships.with_type.with_activity_period.
      with_virtual_attributes(*@memberships_attributes)
    @memberships_column_types = Membership.attribute_db_types
    set_memberships_column_headers

    @title = t('members.show.title', :name => @member.non_sql_full_name)
  end

  def new
    @member = Member.new
    @member.build_person

    render_new_properly
  end

  def edit
    @member = Member.joins(:person).with_virtual_attributes(:full_name).
                     find(params[:id])
    render_edit_properly
  end

  def create

    params[:member].delete(:email) if params[:member][:email].blank?

    # Because members primary key works as foreign key for people
    # (this is not recommended in general),
    # building an associated person and saving the member with person with
    # "@member.save" does not seem to work in rails 3.0.9
    # (probably causes stack overflow).
    # The only workaround seems to be to save the person first,
    # assign the foreign key manually, and then save the member.
    @person = Person.new
    @member = Member.new
    params[:member][:person_attributes].delete(:email) if
      params[:member][:person_attributes][:email].blank?

    @person.assign_attributes(params[:member][:person_attributes])
    @member.assign_attributes(params[:member].except(:person_attributes))

    unless @person.save
      flash.now[:error] = t('flash.members.create.failure')
      @member.person = @person  # seems safe here

      render_new_properly and return
    end

    @member.person_id = @person.id

    if @member.save
      flash[:success] = t('flash.members.create.success',
                          :name => @member.non_sql_full_name)
      redirect_to :action => :show,
                  :id     => @member
    else
      flash.now[:error] = t('flash.members.create.failure')

      render_new_properly
    end
  end

  def update
    @member = Member.joins(:person).with_virtual_attributes(:full_name).
                     find(params[:id])

    params[:member][:person_attributes].delete(:email) if
      params[:member][:person_attributes][:email].blank?

    if @member.update_attributes(params[:member])
      flash[:notice] = t('flash.members.update.success',
                         :name => @member.full_name)

      redirect_to :action => :show,
                  :id     => @member
    else
      flash.now[:error] = t('flash.members.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @member = Member.find(params[:id])
    @member.destroy

    flash[:notice] = t('flash.members.destroy.success',
                       :name => @member.non_sql_full_name)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @column_types = Member.attribute_db_types

      @title = t('members.new.title')

      render :new
    end

    def render_edit_properly
      @column_types = Member.attribute_db_types

      @title =  t('members.edit.title', :name => @member.non_sql_full_name)

      render :edit
    end

    def set_column_headers
      @column_headers = {}
      @attributes.each do |attr|
        @column_headers[attr] = Member.human_attribute_name(attr)

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

    def set_events_column_types
      @events_column_types = {}
      Event.columns_hash.each do |key, value|
        @events_column_types[key.to_sym] = value.type
      end
    end

    def set_events_column_headers
      @events_column_headers = {}
      @attended_events_attributes.each do |attr|
        human_name = Event.human_attribute_name(attr)

        case @events_column_types[attr]
        when :boolean
          @events_column_headers[attr] = I18n.t('formats.attribute_name?',
                                                :attribute => human_name)
        else
          @events_column_headers[attr] = I18n.t('formats.attribute_name:',
                                                :attribute => human_name)
        end
      end
    end

    def set_memberships_column_headers
      @memberships_column_headers = {}
      @memberships_attributes.each do |attr|
        human_name = Membership.human_attribute_name(attr)

        case @memberships_column_types[attr]
        when  :boolean, :delegated_boolean, :virtual_boolean
          @memberships_column_headers[attr] = I18n.t('formats.attribute_name?',
                                                     :attribute => human_name)
        else
          @memberships_column_headers[attr] = I18n.t('formats.attribute_name:',
                                                     :attribute => human_name)
        end
      end
    end

end
