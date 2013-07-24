## encoding: UTF-8

class WeeklyEventsController < ManagerController

  def index
    case request.format
    when Mime::HTML
      @attribute_names = [ :title,
                           :event_type,
                           :lesson,
                           :week_day,
                           :start_time,
                           :duration_minutes,
                           :location,
                           :entry_fee_tickets ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attribute_names = [ :title,
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

    @weekly_events = WeeklyEvent.all

    # Filter:
    @weekly_events = do_filtering(@weekly_events)
    @filtered_weekly_events_count = @weekly_events.count

    # Sort:
    sort_params = (params['sort'] && params['sort']['weekly_events']) || {}
    @weekly_events = sort(@weekly_events, sort_params, :end_on)

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @weekly_events = paginate(@weekly_events)

        render :index
      end

      requested_format.xml do
        render :xml  => @weekly_events,
               :only => @attribute_names
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @weekly_events,
               :only                             => @attribute_names
      end

      requested_format.csv do
        render :collection_csv_zip => @weekly_events,
               :only               => @attribute_names
      end
    end
  end

  def show
    @weekly_event = WeeklyEvent.find(params['id'])

    @attribute_names = [ :title,
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

    @event_attribute_names = [ :title, :event_type,
                               :date,
                               :start_time,
                               :supervisors ]

    @events = @weekly_event.events
    @events_column_headers = Event.human_column_headers

    # Filter:
    @events = do_filtering(@events, params[:filter], @event_attribute_names)
    @filtered_events_count = @events.count

    # Sort:
    sort_params = (params['sort'] && params['sort']['events']) || {}
    @events = sort(@events, sort_params, :date)

    # Paginate:
    @events = paginate(@events)

    @title = t('weekly_events.show.title', :title => @weekly_event.title)
  end

  def new
    @weekly_event = WeeklyEvent.new

    render_new_properly
  end

  def edit
    @weekly_event = WeeklyEvent.find(params['id'])

    render_edit_properly
  end

  def create
    attributes = process_raw_weekly_event_attributes_for_create
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
    @weekly_event = WeeklyEvent.find(params['id'])

    attributes = process_raw_weekly_event_attributes_for_update

    if @weekly_event.update_attributes(attributes)
      flash[:notice] = t('flash.weekly_events.update.success',
                         :title => @weekly_event.title)
      redirect_to :action => :show, :id => @weekly_event
    else
      flash.now[:error] = t('flash.weekly_events.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @weekly_event = WeeklyEvent.find(params['id'])

    @weekly_event.destroy

    flash[:notice] = t('flash.weekly_events.destroy.success',
                       :title => @weekly_event.title)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @attribute_names = [ :title,
                           :event_type,
                           :week_day,
                           :start_time,
                           :end_time,
                           :start_on,
                           :end_on,
                           :location,
                           :entry_fee_tickets,
                           :description ]

      @title = t('weekly_events.new.title')

      render :new
    end

    def render_edit_properly
      @attribute_names = [ :title,
                           :event_type,
                           :week_day,
                           :start_time,
                           :end_time,
                           :start_on,
                           :end_on,
                           :location,
                           :entry_fee_tickets,
                           :description ]

      @title = t('weekly_events.edit.title', :title => @weekly_event.title)

      render :edit
    end

  module AttributesFromParamsForCreate
    WEEKLY_EVENT_ATTRIBUTE_NAMES = Set[ :title,
                                        :event_type,
                                        :week_day,
                                        :start_time,
                                        :end_time,
                                        :start_on,
                                        :end_on,
                                        :location,
                                        :entry_fee_tickets,
                                        :description ]
    WEEKLY_EVENT_ATTRIBUTE_NAMES_FROM_STRINGS =
      WEEKLY_EVENT_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def weekly_event_attribute_name_from_params_key_for_create(params_key)
        WEEKLY_EVENT_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_weekly_event_attributes_for_create(
            submitted_attributes = params['weekly_event'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [weekly_event_attribute_name_from_params_key_for_create(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          [attr_name, value == '' ? nil : value]
        }

        Hash[attributes_in_array].tap do |attributes|
          attributes[:lesson] =
            %w[Cours Atelier Initiation].include?(attributes[:weekly_event_type])
        end
      end

  end
  include AttributesFromParamsForCreate

  module AttributesFromParamsForUpdate
    WEEKLY_EVENT_ATTRIBUTE_NAMES = Set[ :title,
                                        :week_day,
                                        :start_time,
                                        :end_time,
                                        :end_on,
                                        :location,
                                        :entry_fee_tickets,
                                        :description ]
    WEEKLY_EVENT_ATTRIBUTE_NAMES_FROM_STRINGS =
      WEEKLY_EVENT_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def weekly_event_attribute_name_from_params_key_for_update(params_key)
        WEEKLY_EVENT_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_weekly_event_attributes_for_update(
            submitted_attributes = params['weekly_event'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [weekly_event_attribute_name_from_params_key_for_update(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          [attr_name, value == '' ? nil : value]
        }
        Hash[attributes_in_array]
      end

  end
  include AttributesFromParamsForUpdate
end
