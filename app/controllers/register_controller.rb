## encoding: UTF-8

class RegisterController < ApplicationController

  class Member < self::Member
    self.all_sorting_columns = [:ordered_full_name,
                                :email,
                                :employed_from]
    self.default_sorting_column = :ordered_full_name
  end

  def choose_person
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

  def create_event_entry
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
        @tab = 1
        render_compose_transaction_properly
      else
        render_choose_person_properly
      end
    end    
  end

  def create_tickets_purchase
  end

  def create_membership_purchase
  end

  private

    def set_tab_from_params
      @tab = params[:tab].to_i
      @tab = 0 unless (0..2).include?(@tab)
    end

    def set_person_from_params
      if params[:member_id]
        @member = Member.joins(:person)\
                        .with_virtual_attributes(:full_name)\
                        .find(params[:member_id])
      elsif params[:guest]
        @guest = Guest.new(params[:guest])
      end
    end

    def render_choose_person_properly
      @members = paginate(Member.joins(:person)\
                                .with_virtual_attributes(:ordered_full_name)\
                                .default_order)
      @guest ||= Guest.new(params[:guest])
      @title = t('register.choose_person.title')

      render :choose_person
    end

    def render_compose_transaction_properly
      @visitor_name = @member ?
        @member.full_name :
        "#{@guest.first_name} (#{t('activemodel.models.guest')})"

      case @tab
      when 0  # entry
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
      when 1  # tickets
        @tickets_purchase = TicketsPurchase.new
      when 2  # membership
        @membership_purchase = MembershipPurchase.new
      end
      @title = t('register.compose_transaction.title')

      render :compose_transaction
    end

end
