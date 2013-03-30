## encoding: UTF-8

class RegisterController < ApplicationController # FIXME

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

    case params[:button]
    when 'show_participants'
      @participants = @event.participants.default_order
    when 'show_recent_ticket_purchases'
      @recent_ticket_purchases = TicketsPurchase.last_12_hours.default_order
    when 'show_recent_membership_purchases'
      @recent_membership_purchases = MembershipPurchase.last_12_hours.default_order
    end

    render_choose_person_properly
  end

  def new_member_transaction
    unless @member = Member.joins(:person).find(params[:member_id])
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
    @member = Member.find(params[:member_id])

    event_id = params[:event_entry][:event_id]
    if @event = Event.find(event_id)
      session[:current_event_id] = event_id
    else
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    @member.compose_new_event_participation(@event)

    if @member.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => MemberEntry.model_name.human )
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
    @guest = Guest.new(params[:guest])

    event_id = params[:event_entry][:event_id]
    if @event = Event.find(event_id)
      session[:current_event_id] = event_id
    else
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    guest_entry = @guest.compose_new_event_participation(@event)

    if guest_entry.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => GuestEntry.model_name.human)
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

  def create_anonymous_entry
    event_id = params[:event_entry][:event_id]
    if @event = Event.find(event_id)
      session[:current_event_id] = event_id
    else
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    if @event.create_anonymous_entry
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => EventEntry.model_name.human)
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly
    end
  end

  def create_member_ticket_purchase
    @member = Member.find(params[:member_id])

    @ticket_book = TicketBook.find(params[:tickets_purchase][:ticket_book_id])

    @tickets_purchase = @member.compose_new_tickets_purchase(@ticket_book)

    if @member.save
      flash[:success] =
        t('flash.actions.create.success',
          :resource_name => TicketsPurchase.model_name.human)
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      @tab = 'new_ticket_purchase'
      render_new_member_transaction_properly
    end
  end

  def create_member_membership_purchase
    @member = Member.find(params[:member_id])

    @membership = Membership.find(params[:membership_purchase][:membership_id])

    @membership_purchase = @member.compose_new_membership_purchase(@membership)

    if @member.save
      flash[:success] =
        t('flash.actions.create.success',
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
      @members = do_filtering(@members)
      @members_filtering_values = @filtering_values || {}

      @guest ||= Guest.new(params[:guest])

      @member_attributes = [:last_name, :first_name]

      @events = Event.unlocked.past_seven_days

      @saved_params = params.slice(:filter, :sort, :page, :per_page)

      @title = t('register.choose_person.title')

      render :choose_person
    end

    def render_new_member_transaction_properly
      @events = Event.unlocked.past_seven_days

      @attended_event_attributes = [:title, :event_type, :date, :start_time]
      @attended_events = @member.attended_events

      @owned_membership_attributes = [:title, :duration_months, :end_date]
      @owned_memberships =
        @member.memberships.with_type.with_activity_period.
                with_pseudo_columns(*@owned_membership_attributes)

      @tabs = @events.empty? ? [] : ['new_entry']

      if @member.current_membership
        @ticket_books = @member.current_membership.ticket_books
        @tabs << 'new_ticket_purchase' unless @ticket_books.empty?
      end

      @tabs << 'new_membership_purchase'

      @person_name = @member.virtual_full_name

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
      @event_entry = EventEntry.new(:event => @event)
      @event_entry.person_id = @member.person_id
      @attended_events = @member.attended_events.default_order if
        params[:button] == 'show_attended_events'

      render 'new_member_transaction'
    end

    def render_new_guest_entry_properly
      @event ||= @events.first  # FIXME!

      @event_entry = EventEntry.new(:event => @event)

      render 'new_guest_transaction'
    end

    def render_new_member_ticket_purchase_properly
      @memberships = @member.memberships.not_over.reverse_order_by_expiration_date.all
      @ticket_books = []
      @memberships.each do |m|
        @ticket_books += m.ticket_books.default_order.all
      end

      @tickets_purchase ||=
        TicketsPurchase.new(:member      => @member,
                            :ticket_book => @ticket_books.first)

      render 'new_member_transaction'
    end

    def render_new_member_membership_purchase_properly  # FIXME: allow guests to purchase memberships
      @activity_periods = ActivityPeriod.not_over.reverse_order_by_end_date.all
      @memberships = []
      @activity_periods.each do |ap|
        @memberships += ap.memberships.default_order.all
      end

      @membership_purchase ||=
        MembershipPurchase.new(:membership => @memberships.first)

      @membership_purchase.validated_by_user = current_user.username if
        current_user.a_person?

      @membership_purchase.member_id = @member.person_id if @member

      render 'new_member_transaction'
    end

end
