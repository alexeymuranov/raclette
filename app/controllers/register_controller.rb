## encoding: UTF-8

class RegisterController < ApplicationController

  class Member < Member
    self.all_sorting_columns = [ :ordered_full_name,
                                 :email,
                                 :employed_from ]
    self.default_sorting_column = :ordered_full_name
  end

  param_accessible /.+/

  def choose_person
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.delete(:query_type)
    params.delete(:commit)
    params.delete(:button)

    if @query_type == 'filter' && @submit_button == 'clear_button'
      params.delete(:filter)
    end

    render_choose_person_properly
  end

  def compose_transaction
    set_person_from_params
    set_tab_from_params

    unless @member || @guest
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly and return
    end

    event_id = params[:event_id]
    if event_id && @event = Event.find(event_id)
      self.current_event = @event unless event_id == current_event_id
    else
      @event = current_event
    end

    render_compose_transaction_properly
  end

  def create_entry
    event_entry_attributes = params[:event_entry] || {}
    event_id = event_entry_attributes[:event_id]
    if event_id && @event = Event.find(event_id)
      self.current_event = @event unless event_id == current_event_id
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

  def create_ticket_purchase  # FIXME
    tickets_purchase_attributes = params[:tickets_purchase] || {}

    @tickets_purchase = TicketsPurchase.new(tickets_purchase_attributes)
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

  def create_membership_purchase  # FIXME
    membership_purchase_attributes = params[:event_entry] || {}

    @membership_purchase = MembershipPurchase.new(event_entry_attributes)
    if @event_entry.save
      flash[:success] = t('flash.actions.create.success',
                          :resource_name => MembershipPurchase.model_name.human )
      redirect_to :action => :choose_person
    else
      flash.now[:error] = t('flash.actions.other.failure')
      if @member || @guest
        @tab = 'new_membership_purchase'
        render_compose_transaction_properly
      else
        render_choose_person_properly
      end
    end
  end

  private

    def set_person_from_params
      if params[:member_id]
        @member = Member.joins(:person)\
                        .with_virtual_attributes(:full_name)\
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
      @members = paginate(Member.account_active.joins(:person)\
                                .with_virtual_attributes(:ordered_full_name)\
                                .default_order)
      # Filter:
      @members = Member.filter(@members, params[:filter], @attributes)
      @members_filtering_values = Member.last_filter_values

      @guest ||= Guest.new(params[:guest])

      @members_attributes = [ :last_name, :first_name ]
      @members_column_types = Member.attribute_db_types
      @members_column_headers = {}
      @members_attributes.each do |attr|
        @members_column_headers[attr] = Member.human_attribute_name(attr)

        case @members_column_types[attr]
        when :boolean, :delegated_boolean, :virtual_boolean
          @members_column_headers[attr] = I18n.t('formats.attribute_name?',
              :attribute => @members_column_headers[attr])
        else
          @members_column_headers[attr] = I18n.t('formats.attribute_name:',
              :attribute => @members_column_headers[attr])
        end
      end

      @title = t('register.choose_person.title')

      render :choose_person
    end

    def render_compose_transaction_properly
      @tabs = ['new_entry', 'new_ticket_purchase', 'new_membership_purchase']

      if @member
        @person_name = @member.full_name
      else
        @tabs.delete('new_ticket_purchase')
        @person_name = "#{@guest.first_name} "\
                       "(#{t('activemodel.models.guest')})"
      end

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
      @events = Event.all  # FIXME!
      if @events.blank?
        render_choose_person_properly and return
      end
      @event ||= @events.first  # FIXME!
      @event_entry = EventEntry.new(
        :event_id    => @event.id,
        :event_title => @event.title,
        :date        => @event.date )
      if @member
        @event_entry.person_id = @member.person_id
        @event_entry.participant_entry_type = 'MemberEntry'
      else
        @event_entry.participant_entry_type = 'GuestEntry'
      end
      @title = t('register.compose_transaction.title')

      @tab = 'new_entry'
      render 'compose_transaction'
    end

    def render_new_ticket_purchase_properly
      @ticket_books = TicketBook.where(
        :membership_type_id => @member.current_membership.type.id).
        order('tickets_number ASC')
      @ticket_book = @ticket_books.first
      @tickets_purchase = TicketsPurchase.new(
        :member      => @member,
        :ticket_book => @ticket_book )
      @title = t('register.compose_transaction.title')

      @tab = 'new_ticket_purchase'
      render 'compose_transaction'
    end

    def render_new_membership_purchase_properly
      @membership_types = MembershipType.all  # FIXME!
      @membership_type = @membership_types.first
      @activity_periods = ActivityPeriod.all  # FIXME!
      @activity_period = ActivityPeriod.current.reverse_order_by_end_date.first

      @membership_purchase = MembershipPurchase.new(
                               :purchase_date => Date.today )
      @membership_purchase.validated_by_user = current_user.username if
        current_user.a_person?
      @membership_purchase.member_id = @member.person_id if @member
      @title = t('register.compose_transaction.title')

      @tab = 'new_membership_purchase'
      render 'compose_transaction'
    end

end
