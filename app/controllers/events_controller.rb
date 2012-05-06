## encoding: UTF-8

class EventsController < SecretaryController

  class Event < Event
    self.all_sorting_columns = [ :title, :event_type,
                                 :date,
                                 :start_time,
                                 :supervisors ]
    self.default_sorting_column = :date
  end

  param_accessible /.+/

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.except!(:query_type, :commit, :button)

    if @query_type == 'filter' && @submit_button == 'clear_button'
      params.delete(:filter)
    end

    case request.format
    when Mime::HTML
      @attributes = [ :title, :event_type,
                      :date,
                      :start_time,
                      :supervisors ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML
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

    set_column_types

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

    set_column_headers

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

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download\
            @events,
            @attributes,
            @column_headers  # defined in ApplicationController
      end

      requested_format.csv do
        render_csv_for_download\
            @events,
            @attributes,
            @column_headers  # defined in ApplicationController
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

    @event = Event.find(params[:id])

    @column_types = Event.attribute_db_types
    # set_column_headers

    @title = t('events.show.title', :title => @event.title)
  end

  def new
    unless (@weekly_event_id = params[:weekly_event_id]).blank?
      @weekly_event_id = @weekly_event_id.to_i
      @weekly_event = WeeklyEvent.find(@weekly_event_id)
    end

    if @weekly_event
      @event = Event.new(@weekly_event)
    else
      @event = Event.new
    end

    render_new_properly
  end

  def edit
    @event = Event.find(params[:id])

    render_edit_properly
  end

  def create
    attributes = params[:event]
    attributes[:lesson] =
      %w[Cours Atelier Initiation].include?(attributes[:event_type])
    attributes[:weekly_event_id] = params[:weekly_event_id]
    @event = Event.new(attributes)

    if @event.save
      flash[:success] = t('flash.events.create.success',
                          :title => @event.title)
      redirect_to :action => :show, :id => @event
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
                      :weekly,
                      :entry_fee_tickets ]
      @column_types = Event.attribute_db_types

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
      @column_types = Event.attribute_db_types

      @title =  t('events.edit.title', :title => @event.title)

      render :edit
    end

    def set_column_types
      @column_types = {}
      Event.columns_hash.each do |key, value|
        @column_types[key.to_sym] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = Event.human_attribute_name(attr)

        case type
        when :boolean
          @column_headers[attr] = I18n.t('formats.attribute_name?',
                                         :attribute => human_name)
        else
          @column_headers[attr] = I18n.t('formats.attribute_name:',
                                         :attribute => human_name)
        end
      end
    end

end
