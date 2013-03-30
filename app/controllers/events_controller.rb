## encoding: UTF-8

class EventsController < SecretaryController

  class Event < Accessors::Event
    init_associations

    self.all_sorting_columns = [ :title, :event_type,
                                 :date,
                                 :start_time,
                                 :supervisors ]
    self.default_sorting_column = :date
  end

  class WeeklyEvent < Accessors::WeeklyEvent
    init_associations

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
  end

  class Person < Accessors::Person
    init_associations

    self.all_sorting_columns = [:ordered_full_name, :email]
    self.default_sorting_column = :ordered_full_name
  end

  class Member < Accessors::Member
    init_associations

    self.all_sorting_columns = [ :ordered_full_name,
                                 :email,
                                 :account_deactivated,
                                 :tickets_count ]
    self.default_sorting_column = :ordered_full_name
  end

  before_filter :find_event, :only => [:show, :edit, :update, :destroy]

  def index
    case request.format
    when Mime::HTML
      @attributes = [ :title, :event_type,
                      :date,
                      :start_time,
                      :supervisors ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
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

    @events = Event.scoped

    # Filter:
    @events = do_filtering(@events)
    @filtered_events_count = @events.count

    # Sort:
    Event.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:events]) || {}
    @events = Event.sort(@events, sort_params)
    @sorting_column = Event.last_sort_column
    @sorting_direction = Event.last_sort_direction

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @events = paginate(@events)

        render :index
      end

      requested_format.xml do
        render :xml  => @events,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @events,
               :only                             => @attributes
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @events,
               :only               => @attributes
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

    @singular_associations = [:weekly_event]
    @association_name_attributes = { :weekly_event => :virtual_long_title }

    @member_participant_attributes = [:ordered_full_name, :email]
    @member_participants = @event.member_participants.
      with_pseudo_columns(*@member_participant_attributes)

    @other_participant_attributes = [:ordered_full_name, :email]
    @other_participants = @event.non_member_participants.
      with_pseudo_columns(*@other_participant_attributes)

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
    render_edit_properly
  end

  def create
    attributes = params[:event]
    # XXX: this modifies `params` in place (`attibutes` is a shallow copy)
    attributes[:lesson] =
      Set['Cours', 'Atelier', 'Initiation'].include?(attributes[:event_type])
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
    @event.destroy

    flash[:notice] = t('flash.events.destroy.success',
                       :title => @event.title)

    redirect_to :action => :index
  end

  private

    def find_event
      @event = Event.find(params[:id])
    end

    def render_new_properly
      @attributes = [ :title, :event_type,
                      :date,
                      :start_time,
                      :end_time,
                      :supervisors,
                      :location,
                      :entry_fee_tickets ]

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
                      :entry_fee_tickets ]

      @title =  t('events.edit.title', :title => @event.title)

      render :edit
    end

end
