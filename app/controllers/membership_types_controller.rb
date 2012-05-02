## encoding: UTF-8

class MembershipTypesController < ManagerController

  class MembershipType < MembershipType
    self.all_sorting_columns = [ :unique_title,
                                 :active,
                                 :reduced,
                                 :unlimited,
                                 :duration_months,
                                 :description ]
    self.default_sorting_column = :duration_months
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
      @attributes = [ :unique_title,
                      :active,
                      :reduced,
                      :unlimited,
                      :duration_months ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML
      @attributes = [ :unique_title,
                      :active,
                      :reduced,
                      :unlimited,
                      :duration_months,
                      :description ]
    end

    set_column_types

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

    set_column_headers

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

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download @membership_types,
                                              @attributes,
                                              @column_headers
      end

      requested_format.csv do
        render_csv_for_download @membership_types,
                                @attributes,
                                @column_headers
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

    @column_types = MembershipType.attribute_db_types
    # set_column_headers

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
      @column_types = MembershipType.attribute_db_types

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
      @column_types = MembershipType.attribute_db_types

      @title =  t('membership_types.edit.title',
                  :title => @membership_type.unique_title)

      render :edit
    end

    def set_column_types
      @column_types = {}
      MembershipType.columns_hash.each do |key, value|
        @column_types[key.to_sym] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = MembershipType.human_attribute_name(attr)

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
