## encoding: UTF-8

class MembershipsController < ManagerController # FIXME!

  class Membership < Accessors::Membership
    belongs_to :activity_period, :class_name => :ActivityPeriod,
                                 :inverse_of => :memberships
    belongs_to :type, :foreign_key => :membership_type_id,
                      :class_name  => :MembershipType,
                      :inverse_of  => :memberships
  end

  class MembershipType < Accessors::MembershipType
    self.all_sorting_columns = [ :unique_title,
                                 :duration_months,
                                 :active,
                                 :reduced,
                                 :unlimited ]
    self.default_sorting_column = :unique_title
  end

  class ActivityPeriod < Accessors::ActivityPeriod
    self.all_sorting_columns = [:ip, :description]
    self.default_sorting_column = :ip
  end

  before_filter :find_membership, :only => [:show, :edit, :update, :destroy]

  def index
    @membership_types = MembershipType.default_order
    @activity_periods = ActivityPeriod.default_order

    # @title = t('memberships.index.title')
  end

  def show
    @attributes = [:initial_price, :current_price]

    @singular_associations = [:activity_period, :type]
    @association_name_attributes = { :activity_period => :unique_title,
                                     :type            => :unique_title }

    @title = t('memberships.show.title',
               :title => @membership.virtual_title)
  end

  def new
    @membership = Membership.new

    render_new_properly
  end

  def edit
    render_edit_properly
  end

  def create
    @membership = Membership.new(params[:membership])

    if @membership.save
      flash[:success] = t('flash.memberships.create.success',
                          :title => @membership.virtual_title)
      redirect_to :action => :show, :id => @membership
    else
      flash.now[:error] = t('flash.memberships.create.failure')

      render_new_properly
    end
  end

  def update
    if @membership.update_attributes(params[:membership])
      flash[:notice] = t('flash.memberships.update.success',
                         :title => @membership.virtual_title)
      redirect_to :action => :show, :id => @membership
    else
      flash.now[:error] = t('flash.memberships.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @membership.destroy

    flash[:notice] = t('flash.memberships.destroy.success',
                       :title => @membership.virtual_title)

    redirect_to :action => :index
  end

  private

    def find_membership
      @membership = Membership.find(params[:id])
    end

    def render_new_properly
      @attributes = [:initial_price, :current_price]

      @belongs_to_associations = [:activity_period, :type]
      @association_name_attributes = { :activity_period => :unique_title,
                                       :type            => :unique_title }

      @title = t('memberships.new.virtual_title')

      render :new
    end

    def render_edit_properly
      @attributes = [:initial_price, :current_price]

      @belongs_to_associations = [:activity_period, :type]
      @association_name_attributes = { :activity_period => :unique_title,
                                       :type            => :unique_title }

      @title =  t('memberships.edit.title',
                  :title => @membership.virtual_title)

      render :edit
    end

end
