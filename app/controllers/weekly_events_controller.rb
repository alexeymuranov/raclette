## encoding: UTF-8

class WeeklyEventsController < ManagerController

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

  class Event < Accessors::Event
    self.all_sorting_columns = [ :title, :event_type,
                                 :date,
                                 :start_time,
                                 :supervisors ]
    self.default_sorting_column = :date

    belongs_to :weekly_event, :class_name => :WeeklyEvent,
                              :inverse_of => :events
  end

  def index
    @submit_button = params[:button]

    if @submit_button == 'filter'
      params.delete(:page)
    end

    # FIXME: strange if this is necessary:
    params.except!(:commit, :button)

    case request.format
    when Mime::HTML
      @attributes = [ :title,
                      :event_type,
                      :lesson,
                      :week_day,
                      :start_time,
                      :duration_minutes,
                      :location,
                      :entry_fee_tickets ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML, Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attributes = [ :title,
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
                      :description ]
    end

    @column_types = WeeklyEvent.column_db_types

    @weekly_events = WeeklyEvent.scoped

    # Filter:
    @weekly_events = WeeklyEvent.filter(@weekly_events, params[:filter], @attributes)
    @filtering_values = WeeklyEvent.last_filter_values
    @filtered_weekly_events_count = @weekly_events.count

    # Sort:
    WeeklyEvent.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:weekly_events]) || {}
    @weekly_events = WeeklyEvent.sort(@weekly_events, sort_params)
    @sorting_column = WeeklyEvent.last_sort_column
    @sorting_direction = WeeklyEvent.last_sort_direction

    @column_headers = WeeklyEvent.human_column_headers

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @weekly_events = paginate(@weekly_events)

        # @title = t('admin.users.index.title')  # or: WeeklyEvent.model_name.human.pluralize
        render :index
      end

      requested_format.xml do
        render :xml  => @weekly_events,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @weekly_events,
               :only                             => @attributes,
               :headers                          => @column_headers
      end

      requested_format.csv do
        render :collection_csv_zip => @weekly_events,
               :only               => @attributes,
               :headers            => @column_headers
      end
    end
  end

  def show
    @attributes = [ :title,
                    :event_type,
                    :lesson,
                    :week_day,
                    :start_time,
                    :end_time,
                    # :duration_minutes,
                    :start_on,
                    :end_on,
                    :location,
                    :entry_fee_tickets,
                    :description ]

    @weekly_event = WeeklyEvent.find(params[:id])
    @column_types = WeeklyEvent.column_db_types

    @events_attributes = [ :title, :event_type,
                           :date,
                           :start_time,
                           :supervisors ]

    @events = @weekly_event.events
    @events_column_types = Event.column_db_types
    @events_column_headers = Event.human_column_headers

    # Filter:
    @events = Event.filter(@events, params[:filter], @events_attributes)
    @filtering_values = Event.last_filter_values
    @filtered_events_count = @events.count

    # Sort:
    Event.all_sorting_columns = @events_attributes
    sort_params = (params[:sort] && params[:sort][:events]) || {}
    @weekly_events = Event.sort(@events, sort_params)
    @sorting_column = Event.last_sort_column
    @sorting_direction = Event.last_sort_direction

    # Paginate:
    @events = paginate(@events)

    @title = t('weekly_events.show.title', :title => @weekly_event.title)
  end

  def new
    @weekly_event = WeeklyEvent.new

    render_new_properly
  end

  def edit
    @weekly_event = WeeklyEvent.find(params[:id])

    render_edit_properly
  end

  def create
    attributes = params[:weekly_event]
    attributes[:lesson] =
      %w[Cours Atelier Initiation].include?(attributes[:weekly_event_type])
    @weekly_event = WeeklyEvent.new(attributes)
    @weekly_event.build_events

    if @weekly_event.save
      flash[:success] = t('flash.weekly_events.create.success',
                          :title => @weekly_event.title)
      redirect_to :action => :show, :id => @weekly_event
    else
      flash.now[:error] = t('flash.weekly_events.create.failure')

      render_new_properly
    end
  end

  def update
    @weekly_event = WeeklyEvent.find(params[:id])

    if @weekly_event.update_attributes(params[:weekly_event])
      flash[:notice] = t('flash.weekly_events.update.success',
                         :title => @weekly_event.title)
      redirect_to :action => :show, :id => @weekly_event
    else
      flash.now[:error] = t('flash.weekly_events.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @weekly_event = WeeklyEvent.find(params[:id])
    @weekly_event.destroy

    flash[:notice] = t('flash.weekly_events.destroy.success',
                       :title => @weekly_event.title)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @attributes = [ :title,
                      :event_type,
                      :week_day,
                      :start_time,
                      :end_time,
                      :start_on,
                      :end_on,
                      :location,
                      :entry_fee_tickets,
                      :description ]
      @column_types = WeeklyEvent.column_db_types

      @title = t('weekly_events.new.title')

      render :new
    end

    def render_edit_properly
      @attributes = [ :title,
                      :event_type,
                      :week_day,
                      :start_time,
                      :end_time,
                      :start_on,
                      :end_on,
                      :location,
                      :entry_fee_tickets,
                      :description ]
      @column_types = WeeklyEvent.column_db_types

      @title =  t('weekly_events.edit.title', :title => @weekly_event.title)

      render :edit
    end

end
