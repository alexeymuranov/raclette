## encoding: UTF-8

class EventsController < SecretaryController

  # XXX: Experimantal
  class EventResource < Event
    include ActiveModelUtilities

    self.all_sorting_columns = [:title, :event_type,
                                :date,
                                :start_time,
                                :supervisors]
    self.default_sorting_column = :date

    def self.controller_path
      @controller_path ||= EventsController.controller_path
    end

    def controller_path
      self.class.controller_path
    end
  end

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.except!(:query_type, :commit, :button)

    if @query_type == 'filter' && @submit_button == 'clear_button'
      params.delete(:filter)
    end

    case request.format
    when Mime::HTML
      @attributes = [:title, :event_type,
                     :date,
                     :start_time,
                     :supervisors]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML
      @attributes = [:title, :event_type,
                     :date,
                     :start_time,
                     :duration_minutes,
                     :supervisors,
                     :location,
                     :entry_fee_tickets,
                     :entries_count,
                     :tickets_collected,
                     :entry_fees_collected]
    end

    set_column_types

    @events = EventResource.scoped

    # Filter:
    @events = EventResource.filter(@events, params[:filter], @attributes)
    @filtering_values = EventResource.last_filter_values

    # Sort:
    EventResource.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:events]) || {}
    @events = EventResource.sort(@events, sort_params)
    @sorting_column = EventResource.last_sort_column
    @sorting_direction = EventResource.last_sort_direction

    set_column_headers

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @events = paginate(@events)

        # @title = t('admin.users.index.title')  # or: EventResource.model_name.human.pluralize
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
    @attributes = [:title, :event_type,
                   :lesson,
                   :date,
                   :start_time,
                   :duration_minutes,
                   :supervisors,
                   :location,
                   :weekly,
                   :entry_fee_tickets,
                   :entries_count,
                   :tickets_collected,
                   :entry_fees_collected]

    @event = EventResource.find(params[:id])

    @column_types = EventResource.attribute_db_types
    # set_column_headers

    @title = t('events.show.title', :title => @event.title)
  end

  def new
    @event = EventResource.new

    render_new_properly
  end

  def edit
    @event = EventResource.find(params[:id])

    render_edit_properly
  end

  def create
    @event = EventResource.new
    params[:event][:lesson] = ( %w(Cours Atelier Initiation).include?(
                                  params[:event][:event_type]) ?
                                true : false )
    @event.assign_attributes(params[:event])

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
    @event = EventResource.find(params[:id])

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
    @event = EventResource.find(params[:id])
    @event.destroy

    flash[:notice] = t('flash.events.destroy.success',
                       :title => @event.title)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @attributes = [:title, :event_type,
                     :date,
                     :start_time,
                     :duration_minutes,
                     :supervisors,
                     :location,
                     :weekly,
                     :entry_fee_tickets,
                     :entries_count,
                     :tickets_collected,
                     :entry_fees_collected]
      @column_types = EventResource.attribute_db_types

      @title = t('events.new.title')

      render :new
    end

    def render_edit_properly
      @attributes = [:title, :event_type,
                     :date,
                     :start_time,
                     :duration_minutes,
                     :supervisors,
                     :location,
                     :weekly,
                     :entry_fee_tickets,
                     :entries_count,
                     :tickets_collected,
                     :entry_fees_collected]
      @column_types = EventResource.attribute_db_types

      @title =  t('events.edit.title', :title => @event.title)

      render :edit
    end

    def set_column_types
      @column_types = {}
      EventResource.columns_hash.each do |key, value|
        @column_types[key.to_sym] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = EventResource.human_attribute_name(attr)

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
