## encoding: UTF-8

# TODO: implement params processing.

class MembershipTypesController < ManagerController

  def index
    case request.format
    when Mime::HTML
      @attribute_names = [ :unique_title,
                           :active,
                           :reduced,
                           :unlimited,
                           :duration_months ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attribute_names = [ :unique_title,
                           :active,
                           :reduced,
                           :unlimited,
                           :duration_months,
                           :description ]
    end

    @membership_types = MembershipType.scoped

    # Filter:
    @membership_types = do_filtering(@membership_types)
    @filtered_membership_types_count = @membership_types.count

    # Sort:
    sort_params = (params[:sort] && params[:sort][:membership_types]) || {}
    @membership_types = sort(@membership_types, sort_params, :duration_months)

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @membership_types = paginate(@membership_types)

        render :index
      end

      requested_format.xml do
        render :xml  => @membership_types,
               :only => @attribute_names
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @membership_types,
               :only                             => @attribute_names
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @membership_types,
               :only               => @attribute_names
      end
    end
  end

  def show
    @membership_type = MembershipType.find(params['id'])

    @attribute_names = [ :unique_title,
                         :active,
                         :reduced,
                         :unlimited,
                         :duration_months,
                         :description ]

    @title = t('membership_types.show.title',
               :title => @membership_type.unique_title )
  end

  def new
    @membership_type = MembershipType.new

    render_new_properly
  end

  def edit
    @membership_type = MembershipType.find(params['id'])

    render_edit_properly
  end

  def create
    @membership_type = MembershipType.new(params[:membership_type])

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
    @membership_type = MembershipType.find(params['id'])

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
    @membership_type = MembershipType.find(params['id'])

    @membership_type.destroy

    flash[:notice] = t('flash.membership_types.destroy.success',
                       :title => @membership_type.unique_title)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @attribute_names = [ :unique_title,
                           :active,
                           :reduced,
                           :unlimited,
                           :duration_months,
                           :description ]

      @title = t('membership_types.new.title')

      render :new
    end

    def render_edit_properly
      @attribute_names = [ :unique_title,
                           :active,
                           :reduced,
                           :unlimited,
                           :duration_months,
                           :description ]

      @title = t('membership_types.edit.title',
                 :title => @membership_type.unique_title)

      render :edit
    end

  module AttributesFromParamsForCreate
    private
      # TODO: implement
  end
  include AttributesFromParamsForCreate

  module AttributesFromParamsForUpdate
    private
      # TODO: implement
  end
  include AttributesFromParamsForUpdate
end
