## encoding: UTF-8

# TODO: implement params processing.

class RegisterController < ApplicationController # FIXME

  def choose_person
    set_event_from_params_or_session

    case params['button']
    when 'show_participants'
      @participants = @event.participants.default_order
    when 'show_recent_ticket_purchases'
      @recent_ticket_purchases = TicketsPurchase.last_12_hours.default_order
    when 'show_recent_membership_purchases'
      @recent_membership_purchases =
        MembershipPurchase.last_12_hours.default_order
    end

    render_choose_person_properly
  end

  def new_member_transaction
    set_member_joint_person_from_params

    unless @member
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    set_event_from_params_or_session

    render_new_member_transaction_properly
  end

  def new_guest_transaction
    build_guest_from_params

    unless @guest
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    set_event_from_params_or_session

    render_new_guest_transaction_properly
  end

  def create_member_entry
    set_member_from_params

    event_id = params['event_entry']['event_id']
    if @event = Event.find(event_id)
      session['current_event_id'] = event_id
    else
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    @member.compose_new_event_participation(@event)

    if @member.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => MemberEntry.model_name.human)
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
    build_guest_from_params

    event_id = params['event_entry']['event_id']
    if @event = Event.find(event_id)
      session['current_event_id'] = event_id
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
    event_id = params['event_entry']['event_id']
    if @event = Event.find(event_id)
      session['current_event_id'] = event_id
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
    set_member_from_params

    @ticket_book =
      TicketBook.find(params['tickets_purchase']['ticket_book_id'])

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
    set_member_from_params

    @membership =
      Membership.find(params['membership_purchase']['membership_id'])

    @membership_purchase =
      @member.compose_new_membership_purchase(@membership)

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
      if @event_id = params['event_id'] || session['current_event_id']
        if @event = Event.find(@event_id)
          session['current_event_id'] = @event_id
        else
          @event_id = nil
        end
      end
    end

    def set_member_from_params
      @member = Member.find(params['member_id'])
    end

    def set_member_joint_person_from_params
      @member = Member.joins(:person).find(params['member_id'])
    end

    def build_guest_from_params
      attributes = process_raw_guest_attributes_for_create_guest_entry
      @guest = Guest.new(attributes)
    end

    def set_tab_from_params
      @tab = params['tab']
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

      @guest ||= Guest.new(params['guest'])

      @member_attribute_names = [:last_name, :first_name]

      @events = Event.unlocked.past_seven_days

      @saved_params = params.slice(:filter, :sort, :page, :per_page)

      @title = t('register.choose_person.title')

      render :choose_person
    end

    def render_new_member_transaction_properly
      @events = Event.unlocked.past_seven_days

      @attended_event_attribute_names =
        [:title, :event_type, :date, :start_time]
      @attended_events = @member.attended_events

      @owned_membership_attribute_names =
        [:title, :duration_months, :end_date]
      @owned_memberships =
        @member.memberships.with_type.with_activity_period.
                with_pseudo_columns(*@owned_membership_attribute_names)

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
      # @event ||= @events.first  # TODO: look at this
      @event_entry = EventEntry.new(:event => @event)
      @event_entry.person_id = @member.person_id
      if params['button'] == 'show_attended_events'
        @attended_events = @member.attended_events.default_order
      end

      render 'new_member_transaction'
    end

    def render_new_guest_entry_properly
      # @event ||= @events.first  # TODO: look at this
      @event_entry = EventEntry.new(:event => @event)

      render 'new_guest_transaction'
    end

    def render_new_member_ticket_purchase_properly
      @memberships =
        @member.memberships.not_over.reverse_order_by_expiration_date.all
      @ticket_books = []
      @memberships.each do |m|
        @ticket_books.concat(m.ticket_books.default_order.all)
      end

      @tickets_purchase ||=
        TicketsPurchase.new(:member      => @member,
                            :ticket_book => @ticket_books.first)

      render 'new_member_transaction'
    end

    # FIXME: allow guests to purchase memberships
    def render_new_member_membership_purchase_properly
      @activity_periods =
        ActivityPeriod.not_over.reverse_order_by_end_date
      @memberships = []
      @activity_periods.each do |ap|
        @memberships.concat(ap.memberships.default_order)
      end

      @membership_purchase ||=
        MembershipPurchase.new(:membership => @memberships.first)

      if current_user.a_person?
        @membership_purchase.validated_by_user = current_user.username
      end

      if @member
        @membership_purchase.member_id = @member.person_id
      end

      render 'new_member_transaction'
    end

  module AttributesFromParamsForCreateMemberEntry
    private
      # TODO: implement
  end
  include AttributesFromParamsForCreateMemberEntry

  module AttributesFromParamsForCreateGuestEntry
    GUEST_ATTRIBUTE_NAMES =
      Set[:first_name, :last_name, :email, :phone, :note]

    GUEST_ATTRIBUTE_NAMES_FROM_STRINGS =
      GUEST_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def guest_attribute_name_from_params_key_for_create_guest_entry(params_key)
        GUEST_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_guest_attributes_for_create_guest_entry(
            submitted_attributes = params['guest'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [guest_attribute_name_from_params_key_for_create_guest_entry(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          [attr_name, value == '' ? nil : value]
        }
        Hash[attributes_in_array]
      end

  end
  include AttributesFromParamsForCreateGuestEntry

  module AttributesFromParamsForCreateAnonymousEntry
    private
      # TODO: implement
  end
  include AttributesFromParamsForCreateAnonymousEntry

  module AttributesFromParamsForCreateMemberTicketPurchase
    private
      # TODO: implement
  end
  include AttributesFromParamsForCreateMemberTicketPurchase

  module AttributesFromParamsForCreateMemberMembershipPurchase
    private
      # TODO: implement
  end
  include AttributesFromParamsForCreateMemberMembershipPurchase
end
