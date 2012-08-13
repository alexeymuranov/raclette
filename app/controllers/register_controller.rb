## encoding: UTF-8

class RegisterController < ApplicationController

  class Member < Accessors::Member
    self.all_sorting_columns = [ :ordered_full_name,
                                 :email,
                                 :tickets_count ]
    self.default_sorting_column = :ordered_full_name
  end

  class Guest < Accessors::Guest
  end

  class Event < Accessors::Event
  end

  def choose_person
    @event_id = params[:event_id] || session[:current_event_id]

    if @event_id.blank?
      @event_id = nil
    else
      if @event = Event.find(@event_id)
        session[:current_event_id] = @event_id
      else
        @event_id = nil
      end
    end

    render_choose_person_properly
  end

  def new_member_transaction
    @members = Member.joins(:person).with_pseudo_columns(:full_name)

    unless @member = @members.find(params[:member_id])
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    set_event_from_params_or_session

    render_new_member_transaction_properly
  end

  def new_guest_transaction
    unless @guest = Guest.new(params[:guest])
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    set_event_from_params_or_session

    render_new_guest_transaction_properly
  end

  def create_member_entry
    event_entry_attributes = params[:event_entry] || {}
    event_id = event_entry_attributes[:event_id]
    if event_id && @event = Event.find(event_id)
      session[:current_event_id] = event_id
    else
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    @event_entry = EventEntry.new(event_entry_attributes)

    @member_entry = MemberEntry.new(
      :member_id      => @event_entry.person_id,
      :guests_invited => false,
      :tickets_used   => @event.entry_fee_tickets)
    @event_entry.participant_entry = @member_entry

    if @event_entry.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => EventEntry.model_name.human )
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      if @member
        @tab = 'new_entry'
        render_new_member_transaction_properly
      else
        render_choose_person_properly
      end
    end
  end

  def create_guest_entry
    event_entry_attributes = params[:event_entry] || {}
    event_id = event_entry_attributes[:event_id]
    if event_id && @event = Event.find(event_id)
      session[:current_event_id] = event_id
    else
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    @event_entry = EventEntry.new(event_entry_attributes)

    @guest_entry = GuestEntry.new(
      :first_name => params[:guest][:first_name])
    @event_entry.participant_entry = @guest_entry

    if @event_entry.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => EventEntry.model_name.human)
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      if @guest
        @tab = 'new_entry'
        render_new_guest_transaction_properly
      else
        render_choose_person_properly
      end
    end
  end

  def create_member_ticket_purchase
    purchase_attributes = params[:tickets_purchase]
    purchase_attributes[:purchase_date] = Date.today
    @tickets_purchase = TicketsPurchase.new(purchase_attributes)

    if @tickets_purchase.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => TicketsPurchase.model_name.human)
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      @tab = 'new_ticket_purchase'
      render_new_member_transaction_properly
    end
  end

  def create_member_membership_purchase
    purchase_attributes = params[:membership_purchase]
    membership_attributes = purchase_attributes.delete(:membership)

    unless membership = Membership.where(membership_attributes).first
      flash.now[:error] =
        t('flash.register.create_membership_purchase.no_membership_found')
      render_new_member_transaction_properly and return
    end

    purchase_attributes[:membership_id] = membership.id unless membership.nil?
    purchase_attributes[:purchase_date] = Date.today

    @membership_purchase = MembershipPurchase.new(purchase_attributes)

    if @membership_purchase.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => MembershipPurchase.model_name.human)
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      @tab = 'new_membership_purchase'
      render_new_member_transaction_properly
    end
  end

  private

    def set_event_from_params_or_session
      if @event_id = params[:event_id] || session[:current_event_id]
        if @event = Event.find(@event_id)
          session[:current_event_id] = @event_id
        else
          @event_id = nil
        end
      end
    end

    def set_tab_from_params
      @tab = params[:tab]
      @tab = @tabs.first unless @tabs.include?(@tab)
    end

    def render_choose_person_properly
      @members = Member.account_active.joins(:person).
                        with_pseudo_columns(:ordered_full_name).
                        default_order
      @members = paginate(@members)

      # Filter:
      @members = Member.filter(@members, params[:filter], @attributes)
      @members_filtering_values = Member.last_filter_values

      @guest ||= Guest.new(params[:guest])

      @members_attributes = [ :last_name, :first_name ]
      @members_column_types = Member.column_db_types
      @members_column_headers = Member.human_column_headers

      @events = Event.unlocked.past_seven_days

      @participants = @event.participants.default_order if
        params[:button] == 'show_participants'

      @saved_params = params.slice(:filter, :sort, :page, :per_page)

      @title = t('register.choose_person.title')

      render :choose_person
    end

    def render_new_member_transaction_properly
      @member = Member.joins(:person).
                       with_pseudo_columns(:full_name).
                       find(params[:member_id])
      @events = Event.unlocked.past_seven_days

      @tabs = @events.empty? ? [] : ['new_entry']

      if @member.current_membership
        @ticket_books = @member.current_membership.type.ticket_books
        @tabs << 'new_ticket_purchase' unless @ticket_books.empty?
      end

      @tabs << 'new_membership_purchase'

      @person_name = @member.full_name

      @saved_params = params.slice(:participant_entry_type, :person_id)

      @title = t('register.new_transaction.title')

      set_tab_from_params

      case @tab
      when 'new_entry'
        render_new_member_entry_properly
      when 'new_ticket_purchase'
        render_new_member_ticket_purchase_properly
      when 'new_membership_purchase'
        render_new_member_membership_purchase_properly
      end
    end

    def render_new_guest_transaction_properly
      @guest = Guest.new(params[:guest])
      @events = Event.unlocked.past_seven_days
      if @events.empty?
        flash.now[:error] =
          t('flash.register.new_transaction.no_current_events_known')
        render_choose_person_properly and return
      else
        @tabs = ['new_entry']
      end

      @person_name =
        "#{ @guest.first_name } (#{ t('activemodel.models.guest') })"

      @saved_params = params.slice(:participant_entry_type, :guest)

      @title = t('register.new_transaction.title')

      set_tab_from_params

      case @tab
      when 'new_entry'
        render_new_guest_entry_properly
      end
    end

    def render_new_member_entry_properly
      @event ||= @events.first  # FIXME!
      @event_entry = EventEntry.new :event_id => @event.id
      @event_entry.person_id = @member.person_id
      @event_entry.participant_entry_type = 'MemberEntry'
      @attended_events = @member.attended_events.default_order if
        params[:button] == 'show_attended_events'

      render 'new_member_transaction'
    end

    def render_new_guest_entry_properly
      @event ||= @events.first  # FIXME!
      @event_entry = EventEntry.new :event_id => @event.id
      @event_entry.participant_entry_type = 'GuestEntry'

      render 'new_guest_transaction'
    end

    def render_new_member_ticket_purchase_properly
      @ticket_books = @ticket_books.default_order
      @ticket_book = @ticket_books.first
      @tickets_purchase = TicketsPurchase.new :member      => @member,
                                              :ticket_book => @ticket_book

      render 'new_member_transaction'
    end

    def render_new_member_membership_purchase_properly  # FIXME: allow guests to purchase memberships
      @membership_types = MembershipType.all  # FIXME!
      @membership_type = @membership_types.first
      @activity_periods = ActivityPeriod.not_over  # FIXME!
      @activity_period = ActivityPeriod.current.reverse_order_by_end_date.first

      @membership_purchase = MembershipPurchase.new
      @membership_purchase.validated_by_user = current_user.username if
        current_user.a_person?
      @membership_purchase.member_id = @member.person_id if @member

      render 'new_member_transaction'
    end

end
