## encoding: UTF-8

# NOTE: This controller is used to test changes before applying them to
# all controllers.

class MembersController < SecretaryController

  class Member < Accessors::Member
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

  class Membership < Accessors::Membership
  end

  class Event < Accessors::Event
    self.all_sorting_columns = [ :title, :event_type,
                                 :date,
                                 :start_time ]
    self.default_sorting_column = :date
  end

  class MembershipType < Accessors::MembershipType
    self.all_sorting_columns = [ :username,
                                 :full_name,
                                 :account_deactivated,
                                 :admin,
                                 :manager,
                                 :secretary,
                                 :a_person ]
    self.default_sorting_column = :username
  end

  class ActivityPeriod < Accessors::ActivityPeriod
    self.all_sorting_columns = [:ip, :description]
    self.default_sorting_column = :ip
  end

  before_filter :find_member, :only => [:show, :edit, :update, :destroy]

  def index
    case request.format
    when Mime::HTML
      @attributes = [ :ordered_full_name,
                      :email,
                      :account_deactivated,
                      :tickets_count ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attributes = [ :last_name,
                      :first_name,
                      :nickname_or_other,
                      :email,
                      :tickets_count ]
    end

    @members = Member.joins(:person).
      with_pseudo_columns(*@attributes, :formatted_email)

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

    respond_to do |requested_format|
      requested_format.html do
        # Paginate:
        @members = paginate(@members)

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
        render :xml  => @members,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml do
        render :collection_ms_excel_2003_xml => @members,
               :only                         => @attributes
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @members,
               :only                             => @attributes
      end

      requested_format.csv do
        render :collection_csv => @members,
               :only           => @attributes
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @members,
               :only               => @attributes
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

    @attended_event_attributes = [:title, :event_type, :date, :start_time]
    @attended_events = @member.attended_events

    @membership_attributes = [:title, :duration_months, :end_date]
    @memberships = @member.memberships.with_type.with_activity_period.
      with_pseudo_columns(*@membership_attributes)

    @title = t('members.show.title', :name => @member.virtual_full_name)
  end

  def new
    @member = Member.new
    @member.build_person

    render_new_properly
  end

  def edit
    render_edit_properly
  end

  def create
    params['member']['person_attributes'].tap { |h|
      h.each_pair do |k, v| h[k] = nil if v.blank? end
      h['nickname_or_other'] ||= ''
    }
    params['member'].tap { |h|
      h.each_pair do |k, v| h[k] = nil if v.blank? end
    }

    # Because members primary key works as foreign key for people
    # (this is not recommended in general),
    # building an associated person and saving the member with person with
    # "@member.save" does not seem to work in rails 3.0.9
    # (probably causes stack overflow).
    # The only workaround seems to be to save the person first,
    # assign the foreign key manually, and then save the member.
    @person = Person.new(params[:member][:person_attributes])
    @member = Member.new(params[:member].except(:person_attributes))
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
    params['member']['person_attributes'].tap { |h|
      h.each_pair do |k, v| h[k] = nil if v.blank? end
      h['nickname_or_other'] ||= ''
    }
    params['member'].tap { |h|
      h.each_pair do |k, v| h[k] = nil if v.blank? end
    }

    if @member.update_attributes(params[:member])
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

    def find_member
      @member = Member.find(params[:id])
    end

    def render_new_properly
      @title = t('members.new.title')

      render :new
    end

    def render_edit_properly
      @title =  t('members.edit.title', :name => @member.virtual_full_name)

      render :edit
    end

end
