## encoding: UTF-8

class MembershipTypesController < ManagerController

  class MembershipType < Accessors::MembershipType
    self.all_sorting_columns = [ :unique_title,
                                 :active,
                                 :reduced,
                                 :unlimited,
                                 :duration_months,
                                 :description ]
    self.default_sorting_column = :duration_months
  end

  def index
    @submit_button = params[:button]

    # FIXME: strange if this is necessary:
    params.except!(:query_type, :commit, :button)

    case request.format
    when Mime::HTML
      @attributes = [ :unique_title,
                      :active,
                      :reduced,
                      :unlimited,
                      :duration_months ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML, Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attributes = [ :unique_title,
                      :active,
                      :reduced,
                      :unlimited,
                      :duration_months,
                      :description ]
    end

    @column_types = MembershipType.column_db_types

    @membership_types = MembershipType.scoped

    # Filter:
    @membership_types = MembershipType.filter(@membership_types,
                                              params[:filter],
                                              @attributes)
    @filtering_values = MembershipType.last_filter_values
    @filtered_membership_types_count = @membership_types.count

    # Sort:
    MembershipType.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:membership_types]) || {}
    @membership_types = MembershipType.sort(@membership_types, sort_params)
    @sorting_column = MembershipType.last_sort_column
    @sorting_direction = MembershipType.last_sort_direction

    @column_headers = MembershipType.human_column_headers

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @membership_types = paginate(@membership_types)

        # @title = t('membership_types.index.title')  # or: MembershipType.model_name.human.pluralize
        render :index
      end

      requested_format.xml do
        render :xml  => @membership_types,
               :only => @attributes
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @membership_types,
               :only                             => @attributes,
               :headers                          => @column_headers
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @membership_types,
               :only               => @attributes,
               :headers            => @column_headers
      end
    end
  end

  def show
    @attributes = [ :unique_title,
                    :active,
                    :reduced,
                    :unlimited,
                    :duration_months,
                    :description ]

    @membership_type = MembershipType.find(params[:id])

    @column_types = MembershipType.column_db_types

    @title = t('membership_types.show.title',
               :title => @membership_type.unique_title )
  end

  def new
    @membership_type = MembershipType.new

    render_new_properly
  end

  def edit
    @membership_type = MembershipType.find(params[:id])

    render_edit_properly
  end

  def create
    @membership_type = MembershipType.new
    @membership_type.assign_attributes(params[:membership_type])

    if @membership_type.save
      flash[:success] = t('flash.membership_types.create.success',
                          :title => @membership_type.unique_title)
      redirect_to :action => :show, :id => @membership_type
    else
      flash.now[:error] = t('flash.membership_types.create.failure')

      render_new_properly
    end
  end

  def update
    @membership_type = MembershipType.find(params[:id])

    if @membership_type.update_attributes(params[:membership_type])
      flash[:notice] = t('flash.membership_types.update.success',
                         :title => @membership_type.unique_title)
      redirect_to :action => :show, :id => @membership_type
    else
      flash.now[:error] = t('flash.membership_types.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @membership_type = MembershipType.find(params[:id])
    @membership_type.destroy

    flash[:notice] = t('flash.membership_types.destroy.success',
                       :title => @membership_type.unique_title)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @attributes = [ :unique_title,
                      :active,
                      :reduced,
                      :unlimited,
                      :duration_months,
                      :description ]
      @column_types = MembershipType.column_db_types

      @title = t('membership_types.new.title')

      render :new
    end

    def render_edit_properly
      @attributes = [ :unique_title,
                      :active,
                      :reduced,
                      :unlimited,
                      :duration_months,
                      :description ]
      @column_types = MembershipType.column_db_types

      @title =  t('membership_types.edit.title',
                  :title => @membership_type.unique_title)

      render :edit
    end

end
