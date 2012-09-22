## encoding: UTF-8

class ActivityPeriodsController < ManagerController

  class ActivityPeriod < Accessors::ActivityPeriod
    self.all_sorting_columns = [ :unique_title,
                                 :start_date,
                                 :duration_months,
                                 :end_date,
                                 :over ]
    self.default_sorting_column = :start_date
  end

  before_filter :find_activity_period, :only => [:show, :edit, :update, :destroy]

  def index
    case request.format
    when Mime::HTML
      @attributes = [ :unique_title,
                      :start_date,
                      :duration_months,
                      :end_date,
                      :over ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attributes = [ :unique_title,
                      :start_date,
                      :duration_months,
                      :end_date,
                      :over,
                      :description ]
    end

    @activity_periods = ActivityPeriod.scoped

    # Filter:
    @activity_periods = ActivityPeriod.filter(@activity_periods,
                                              params[:filter],
                                              @attributes)
    @filtering_values = ActivityPeriod.last_filter_values

    # Sort:
    ActivityPeriod.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:activity_periods]) || {}
    @activity_periods = ActivityPeriod.sort(@activity_periods, sort_params)
    @sorting_column = ActivityPeriod.last_sort_column
    @sorting_direction = ActivityPeriod.last_sort_direction

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @activity_periods = paginate(@activity_periods)

        # @title = t('activity_periods.index.title')  # or: ActivityPeriod.model_name.human.pluralize
        render :index
      end

      requested_format.xml do
        render :xml  => @activity_periods,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @activity_periods,
               :only                             => @attributes
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @activity_periods,
               :only               => @attributes
      end
    end
  end

  def show
    @attributes = [ :unique_title,
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
    render_edit_properly
  end

  def create
    @activity_period = ActivityPeriod.new(params[:activity_period])

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
    if @activity_period.update_attributes(params[:activity_period])
      flash[:notice] = t('flash.activity_periods.update.success',
                         :title => @activity_period.unique_title)
      redirect_to :action => :show, :id => @activity_period
    else
      flash.now[:error] = t('flash.activity_periods.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @activity_period.destroy

    flash[:notice] = t('flash.activity_periods.destroy.success',
                       :title => @activity_period.unique_title)

    redirect_to :action => :index
  end

  private

    def find_activity_period
      @activity_period = ActivityPeriod.find(params[:id])
    end

    def render_new_properly
      @attributes = [ :unique_title,
                      :start_date,
                      :duration_months,
                      :end_date,
                      :over,
                      :description ]

      @title = t('activity_periods.new.title')

      render :new
    end

    def render_edit_properly
      @attributes = [ :unique_title,
                      :start_date,
                      :duration_months,
                      :end_date,
                      :over,
                      :description ]

      @title =  t('activity_periods.edit.title',
                  :title => @activity_period.unique_title)

      render :edit
    end

end
