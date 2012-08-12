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
    @submit_button = params[:button]

    if @submit_button == 'clear'
      params.delete(:filter)
    end

    if @submit_button == 'filter' || @submit_button == 'clear'
      params.delete(:page)
    end

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

  def compose_transaction # TODO: to be removed
    set_person_from_params
    set_tab_from_params

    unless @member || @guest
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    set_event_from_params_or_session

    render_compose_transaction_properly
  end

  def new_member_transaction
    @member = Member.joins(:person)\
                    .with_pseudo_columns(:full_name)\
                    .find(params[:member_id])

    set_tab_from_params

    unless @member
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    set_event_from_params_or_session

    render_compose_transaction_properly
  end

  def new_guest_transaction
    @guest = Guest.new(params[:guest])

    set_tab_from_params

    unless @guest
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    set_event_from_params_or_session

    render_compose_transaction_properly
  end

  def create_entry # TODO: to be removed
    event_entry_attributes = params[:event_entry] || {}
    event_id = event_entry_attributes[:event_id]
    if event_id && @event = Event.find(event_id)
      session[:current_event_id] = event_id
    else
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    @event_entry = EventEntry.new(event_entry_attributes)
    case @event_entry.participant_entry_type
    when 'MemberEntry'
      @member_entry = MemberEntry.new(
        :member_id      => @event_entry.person_id,
        :guests_invited => false,
        :tickets_used   => @event.entry_fee_tickets )
      @event_entry.participant_entry = @member_entry
    when 'GuestEntry'
      @guest_entry = GuestEntry.new(
        :first_name => params[:guest][:first_name] )
      @event_entry.participant_entry = @guest_entry
    end
    if @event_entry.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => EventEntry.model_name.human )
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      if @member || @guest
        @tab = 'new_entry'
        render_compose_transaction_properly
      else
        render_choose_person_properly
      end
    end
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
      :tickets_used   => @event.entry_fee_tickets )
    @event_entry.participant_entry = @member_entry

    if @event_entry.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => EventEntry.model_name.human )
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      if @member
        @tab = 'new_entry'
        render_compose_transaction_properly
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
      :first_name => params[:guest][:first_name] )
    @event_entry.participant_entry = @guest_entry

    if @event_entry.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => EventEntry.model_name.human )
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      if @guest
        @tab = 'new_entry'
        render_compose_transaction_properly
      else
        render_choose_person_properly
      end
    end
  end

  def create_member_ticket_purchase  # FIXME
    @tickets_purchase = TicketsPurchase.new(params[:tickets_purchase])

    @tickets_purchase.tickets_number =
      @tickets_purchase.ticket_book.tickets_number
    @tickets_purchase.purchase_date = Date.today

    if @tickets_purchase.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => TicketsPurchase.model_name.human )
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      if @member
        @tab = 'new_ticket_purchase'
        render_compose_transaction_properly
      else
        render_choose_person_properly
      end
    end
  end

  def create_member_membership_purchase  # FIXME
    purchase_attributes = params[:membership_purchase]
    purchase_attributes[:membership_id] = Membership.
      find_or_create_by_membership_type_id_and_activity_period_id(
        purchase_attributes[:membership_type_id].to_i,
        purchase_attributes[:activity_period_id].to_i).id
    purchase_attributes.except!(:membership_type_id, :activity_period_id)

    @membership_purchase = MembershipPurchase.new(purchase_attributes)

    @membership_purchase.membership_type =
      @membership_purchase.membership.type.unique_title
    @membership_purchase.membership_expiration_date =
      @membership_purchase.membership.end_date
    @membership_purchase.purchase_date = Date.today

    if @membership_purchase.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => MembershipPurchase.model_name.human )
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      if @member
        @tab = 'new_membership_purchase'
        render_compose_transaction_properly
      else
        render_choose_person_properly
      end
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

    def set_person_from_params
      if params[:member_id]
        @member = Member.joins(:person)\
                        .with_pseudo_columns(:full_name)\
                        .find(params[:member_id])
      elsif params[:guest]
        @guest = Guest.new(params[:guest])
      end
    end

    def set_tab_from_params
      @tab = params[:tab]
      @tab = 'new_entry' unless
        @tab == 'new_membership_purchase' ||
        (@member && @tab == 'new_ticket_purchase')
    end

    def render_choose_person_properly
      @members = paginate(Member.account_active.joins(:person).
                                 with_pseudo_columns(:ordered_full_name).
                                 default_order)
      # Filter:
      @members = Member.filter(@members, params[:filter], @attributes)
      @members_filtering_values = Member.last_filter_values

      @guest ||= Guest.new(params[:guest])

      @members_attributes = [ :last_name, :first_name ]
      @members_column_types = Member.column_db_types
      @members_column_headers = {}
      @members_attributes.each do |attr|
        @members_column_headers[attr] = Member.human_attribute_name(attr)

        case @members_column_types[attr]
        when :boolean
          @members_column_headers[attr] = I18n.t('formats.attribute_name?',
              :attribute => @members_column_headers[attr])
        else
          @members_column_headers[attr] = I18n.t('formats.attribute_name:',
              :attribute => @members_column_headers[attr])
        end
      end

      @events = Event.unlocked.past_seven_days

      if params[:button] == 'show_participants'
        @participants = @event.participants.default_order
      end

      saved_param_names = [:filter, :sort, :page, :per_page]
      @saved_params = params.slice(*saved_param_names)

      @title = t('register.choose_person.title')

      render :choose_person
    end

    def render_compose_transaction_properly
      @tabs = ['new_entry', 'new_ticket_purchase', 'new_membership_purchase']

      if @member
        @person_name = @member.full_name
      else
        @tabs.delete('new_ticket_purchase')
        @person_name = "#{ @guest.first_name } "\
                       "(#{ t('activemodel.models.guest') })"
      end

      saved_param_names = [:participant_entry_type]
      saved_param_names << :person_id if @member
      saved_param_names << :guest if @guest
      @saved_params = params.slice(*saved_param_names)

      @title = t('register.compose_transaction.title')

      case @tab
      when 'new_entry'
        render_new_entry_properly
      when 'new_ticket_purchase'
        render_new_ticket_purchase_properly
      when 'new_membership_purchase'
        render_new_membership_purchase_properly
      end
    end

    def render_new_entry_properly
      @events = Event.unlocked.past_seven_days
      if @events.empty?
        render_choose_person_properly and return
      end
      @event ||= @events.first  # FIXME!
      @event_entry = EventEntry.new :event_id => @event.id
      if @member
        @event_entry.person_id = @member.person_id
        @event_entry.participant_entry_type = 'MemberEntry'
        if params[:button] == 'show_attended_events'
          @attended_events = @member.attended_events.default_order
        end
      else
        @event_entry.participant_entry_type = 'GuestEntry'
      end

      render 'compose_transaction'
    end

    def render_new_ticket_purchase_properly
      @ticket_books = TicketBook.where(
        :membership_type_id => @member.current_membership.type.id).
        order('tickets_number ASC')
      @ticket_book = @ticket_books.first
      @tickets_purchase = TicketsPurchase.new :member      => @member,
                                              :ticket_book => @ticket_book

      render 'compose_transaction'
    end

    def render_new_membership_purchase_properly  # FIXME: allow guests to purchase memberships
      @membership_types = MembershipType.all  # FIXME!
      @membership_type = @membership_types.first
      @activity_periods = ActivityPeriod.not_over  # FIXME!
      @activity_period = ActivityPeriod.current.reverse_order_by_end_date.first

      @membership_purchase = MembershipPurchase.new
      @membership_purchase.validated_by_user = current_user.username if
        current_user.a_person?
      @membership_purchase.member_id = @member.person_id if @member

      render 'compose_transaction'
    end

end
