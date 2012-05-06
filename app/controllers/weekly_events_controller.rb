## encoding: UTF-8

class WeeklyEventsController < ManagerController

  class WeeklyEvent < WeeklyEvent
    self.all_sorting_columns = [ :title,
                                 :event_type,
                                 :lesson,
                                 :week_day,
                                 :start_time,
                                 :duration,
                                 :end_time,
                                 :start_on,
                                 :end_on,
                                 :location,
                                 :entry_fee_tickets,
                                 :over,
                                 :description ]
    self.default_sorting_column = :end_on
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
      @attributes = [ :title,
                      :event_type,
                      :lesson,
                      :week_day,
                      :start_time,
                      :duration,
                      :location,
                      :entry_fee_tickets ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML
      @attributes = [ :title,
                      :event_type,
                      :lesson,
                      :week_day,
                      :start_time,
                      :duration,
                      :end_time,
                      :start_on,
                      :end_on,
                      :location,
                      :entry_fee_tickets,
                      :description ]
    end

    set_column_types

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

    set_column_headers

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

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download\
            @weekly_events,
            @attributes,
            @column_headers  # defined in ApplicationController
      end

      requested_format.csv do
        render_csv_for_download\
            @weekly_events,
            @attributes,
            @column_headers  # defined in ApplicationController
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
                    # :duration,
                    :start_on,
                    :end_on,
                    :location,
                    :entry_fee_tickets,
                    :description ]

    @weekly_event = WeeklyEvent.find(params[:id])

    @column_types = WeeklyEvent.attribute_db_types
    # set_column_headers

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
      @column_types = WeeklyEvent.attribute_db_types

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
      @column_types = WeeklyEvent.attribute_db_types

      @title =  t('weekly_events.edit.title', :title => @weekly_event.title)

      render :edit
    end

    def set_column_types
      @column_types = {}
      WeeklyEvent.columns_hash.each do |key, value|
        @column_types[key.to_sym] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = WeeklyEvent.human_attribute_name(attr)

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
