## encoding: UTF-8

class ActivityPeriodsController < ManagerController

  def index
    case request.format
    when Mime::HTML
      @attribute_names = [ :unique_title,
                           :start_date,
                           :duration_months,
                           :end_date,
                           :over ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attribute_names = [ :unique_title,
                           :start_date,
                           :duration_months,
                           :end_date,
                           :over,
                           :description ]
    end

    @activity_periods = ActivityPeriod.all

    # Filter:
    @activity_periods = do_filtering(@activity_periods)
    @filtered_activity_periods_count = @activity_periods.count

    # Sort:
    sort_params = (params[:sort] && params[:sort][:activity_periods]) || {}
    @activity_periods = sort(@activity_periods, sort_params, :start_date)

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @activity_periods = paginate(@activity_periods)

        render :index
      end

      requested_format.xml do
        render :xml  => @activity_periods,
               :only => @attribute_names
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @activity_periods,
               :only                             => @attribute_names
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @activity_periods,
               :only               => @attribute_names
      end
    end
  end

  def show
    @activity_period = ActivityPeriod.find(params['id'])

    @attribute_names = [ :unique_title,
                         :start_date,
                         :duration_months,
                         :end_date,
                         :over,
                         :description ]

    @title = t('activity_periods.show.title',
               :title => @activity_period.unique_title)
  end

  def new
    @activity_period = ActivityPeriod.new

    render_new_properly
  end

  def edit
    @activity_period = ActivityPeriod.find(params['id'])

    render_edit_properly
  end

  def create
    attributes = process_raw_activity_period_attributes_for_create

    @activity_period = ActivityPeriod.new(attributes)

    if @activity_period.save
      flash[:success] = t('flash.activity_periods.create.success',
                          :title => @activity_period.unique_title)
      redirect_to :action => :show, :id => @activity_period
    else
      flash.now[:error] = t('flash.activity_periods.create.failure')

      render_new_properly
    end
  end

  def update
    @activity_period = ActivityPeriod.find(params['id'])

    attributes = process_raw_activity_period_attributes_for_update

    if @activity_period.update_attributes(attributes)
      flash[:notice] = t('flash.activity_periods.update.success',
                         :title => @activity_period.unique_title)
      redirect_to :action => :show, :id => @activity_period
    else
      flash.now[:error] = t('flash.activity_periods.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @activity_period = ActivityPeriod.find(params['id'])

    @activity_period.destroy

    flash[:notice] = t('flash.activity_periods.destroy.success',
                       :title => @activity_period.unique_title)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @attribute_names = [ :unique_title,
                           :start_date,
                           :duration_months,
                           :end_date,
                           :over,
                           :description ]

      @title = t('activity_periods.new.title')

      render :new
    end

    def render_edit_properly
      @attribute_names = [ :unique_title,
                           :start_date,
                           :duration_months,
                           :end_date,
                           :over,
                           :description ]

      @title = t('activity_periods.edit.title',
                 :title => @activity_period.unique_title)

      render :edit
    end

  module AttributesFromParamsForCreate
    ACTIVITY_PERIOD_ATTRIBUTE_NAMES = Set[ :unique_title,
                                           :start_date,
                                           :duration_months,
                                           :end_date,
                                           :over,
                                           :description ]
    ACTIVITY_PERIOD_ATTRIBUTE_NAMES_FROM_STRINGS =
      ACTIVITY_PERIOD_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def activity_period_attribute_name_from_params_key_for_create(params_key)
        ACTIVITY_PERIOD_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_activity_period_attributes_for_create(
            submitted_attributes = params['activity_period'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [activity_period_attribute_name_from_params_key_for_create(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          [attr_name, value == '' ? nil : value]
        }
        Hash[attributes_in_array]
      end

  end
  include AttributesFromParamsForCreate

  module AttributesFromParamsForUpdate
    ACTIVITY_PERIOD_ATTRIBUTE_NAMES =
      AttributesFromParamsForCreate::ACTIVITY_PERIOD_ATTRIBUTE_NAMES
    ACTIVITY_PERIOD_ATTRIBUTE_NAMES_FROM_STRINGS =
      AttributesFromParamsForCreate::ACTIVITY_PERIOD_ATTRIBUTE_NAMES_FROM_STRINGS

    private

      def activity_period_attribute_name_from_params_key_for_update(params_key)
        ACTIVITY_PERIOD_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_activity_period_attributes_for_update(
            submitted_attributes = params['activity_period'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [activity_period_attribute_name_from_params_key_for_update(key), value]
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
