## encoding: UTF-8

class EventsController < SecretaryController

  class Event < Accessors::Event
    self.all_sorting_columns = [ :title, :event_type,
                                 :date,
                                 :start_time,
                                 :supervisors ]
    self.default_sorting_column = :date

    has_many :participants, :through    => :event_entries,
                            :source     => :person,
                            :class_name => :Person

    belongs_to :weekly_event, :class_name => :WeeklyEvent,
                              :inverse_of => :events
  end

  class WeeklyEvent < Accessors::WeeklyEvent
    self.all_sorting_columns = [ :title,
                                 :event_type,
                                 :lesson,
                                 :week_day,
                                 :start_time,
                                 :duration_minutes,
                                 :end_time,
                                 :start_on,
                                 :end_on,
                                 :location,
                                 :entry_fee_tickets,
                                 :over,
                                 :description ]
    self.default_sorting_column = :end_on

    has_many :events, :class_name => :Event,
                      :dependent  => :nullify,
                      :inverse_of => :weekly_event
  end

  class Person < Accessors::Person
    self.all_sorting_columns = [ :ordered_full_name,
                                 :email ]
    self.default_sorting_column = :ordered_full_name

    has_one :member, :dependent  => :destroy,
                     :class_name => :Member,
                     :inverse_of => :person
  end

  class Member < Accessors::Member
    self.all_sorting_columns = [ :ordered_full_name,
                                 :email,
                                 :account_deactivated,
                                 :tickets_count ]
    self.default_sorting_column = :ordered_full_name

    belongs_to :person, :class_name => :Person,
                        :inverse_of => :member
  end

  def index
    @submit_button = params[:button]

    if @submit_button == 'clear'
      params.delete(:filter)
    end

    if  @submit_button == 'filter' || @submit_button == 'clear'
      params.delete(:page)
    end

    # FIXME: strange if this is necessary:
    params.except!(:commit, :button)

    case request.format
    when Mime::HTML
      @attributes = [ :title, :event_type,
                      :date,
                      :start_time,
                      :supervisors ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML, Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attributes = [ :title, :event_type,
                      :date,
                      :start_time,
                      :duration_minutes,
                      :supervisors,
                      :location,
                      :entry_fee_tickets,
                      :entries_count,
                      :tickets_collected,
                      :entry_fees_collected ]
    end

    @column_types = Event.column_db_types

    @events = Event.scoped

    # Filter:
    @events = Event.filter(@events, params[:filter], @attributes)
    @filtering_values = Event.last_filter_values
    @filtered_events_count = @events.count

    # Sort:
    Event.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:events]) || {}
    @events = Event.sort(@events, sort_params)
    @sorting_column = Event.last_sort_column
    @sorting_direction = Event.last_sort_direction
    @column_headers = Event.human_column_headers

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @events = paginate(@events)

        # @title = t('admin.users.index.title')  # or: Event.model_name.human.pluralize
        render :index
      end

      requested_format.xml do
        render :xml  => @events,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @events,
               :only                             => @attributes,
               :headers                          => @column_headers
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @events,
               :only               => @attributes,
               :headers            => @column_headers
      end
    end
  end

  def show
    @attributes = [ :title, :event_type,
                    :lesson,
                    :date,
                    :start_time,
                    :end_time,
                    # :duration_minutes,
                    :supervisors,
                    :location,
                    :weekly,
                    :entry_fee_tickets,
                    :entries_count,
                    :tickets_collected,
                    :entry_fees_collected ]

    @singular_associations = [ :weekly_event ]
    @association_name_attributes = {
      :weekly_event => :virtual_long_title }

    @event = Event.find(params[:id])

    @column_types = Event.column_db_types

    @member_participants_attributes = [ :ordered_full_name, :email ]
    @member_participants = @event.member_participants.
      with_pseudo_columns(*@member_participants_attributes)
    @member_participants_column_types = Member.column_db_types
    @member_participants_column_headers = Member.human_column_headers

    @other_participants_attributes = [ :ordered_full_name, :email ]
    @other_participants = @event.non_member_participants.
      with_pseudo_columns(*@other_participants_attributes)
    @other_participants_column_types = Person.column_db_types
    @other_participants_column_headers = Person.human_column_headers

    @title = t('events.show.title', :title => @event.title)
  end

  def new
    @event = Event.new(params[:event])

    if params[:button] == 'select_weekly_event'
      @event.set_attributes_from_weekly_event
    end

    render_new_properly
  end

  def edit
    @event = Event.find(params[:id])

    render_edit_properly
  end

  def create
    attributes = params[:event]
    # XXX: this modifies `params` in place (`attibutes` is a shallow copy)
    attributes[:lesson] =
      %w[Cours Atelier Initiation].include?(attributes[:event_type])
    @event = Event.new(attributes)

    if @event.save
      flash[:success] = t('flash.events.create.success',
                          :title => @event.title)
      redirect_to :action => :show,
                  :id     => @event
    else
      flash.now[:error] = t('flash.events.create.failure')

      render_new_properly
    end
  end

  def update
    @event = Event.find(params[:id])

    if @event.update_attributes(params[:event])
      flash[:notice] = t('flash.events.update.success',
                         :title => @event.title)
      redirect_to :action => :show, :id => @event
    else
      flash.now[:error] = t('flash.events.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    flash[:notice] = t('flash.events.destroy.success',
                       :title => @event.title)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @attributes = [ :title, :event_type,
                      :date,
                      :start_time,
                      :end_time,
                      :supervisors,
                      :location,
                      # :weekly,
                      :entry_fee_tickets ]
      @column_types = Event.column_db_types

      @weekly_events = WeeklyEvent.not_over

      @title = t('events.new.title')

      render :new
    end

    def render_edit_properly
      @attributes = [ :title, :event_type,
                      :date,
                      :start_time,
                      :end_time,
                      :supervisors,
                      :location,
                      :weekly,
                      :entry_fee_tickets,
                      :entries_count,
                      :tickets_collected,
                      :entry_fees_collected ]
      @column_types = Event.column_db_types

      @title =  t('events.edit.title', :title => @event.title)

      render :edit
    end

end
