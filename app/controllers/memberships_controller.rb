## encoding: UTF-8

class MembershipsController < ManagerController

  before_filter :find_membership, :only => [:show, :edit, :update, :destroy]

  def index
    @membership_types = MembershipType.default_order
    @activity_periods = ActivityPeriod.default_order
  end

  def show
    @attributes = [:initial_price, :current_price]

    @singular_associations = [:activity_period, :membership_type]
    @association_name_attributes = { :activity_period => :unique_title,
                                     :membership_type => :unique_title }

    @ticket_book_attributes = [:tickets_number, :price]

    @ticket_books = @membership.ticket_books
    # @ticket_books_column_headers = TicketBook.human_column_headers

    # Sort:
    sort_params = (params[:sort] && params[:sort][:ticket_books]) || {}
    @ticket_books = sort(@ticket_books, sort_params, :tickets_number)

    @title = t('memberships.show.title',
               :title => @membership.virtual_title)
  end

  def new
    @membership =
      Membership.new(params.slice(:activity_period_id, :membership_type_id))

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

      @belongs_to_associations = [:activity_period, :membership_type]
      @association_name_attributes = { :activity_period => :unique_title,
                                       :membership_type => :unique_title }

      @title = t('memberships.new.virtual_title')

      render :new
    end

    def render_edit_properly
      @attributes = [:initial_price, :current_price]

      @belongs_to_associations = [:activity_period, :membership_type]
      @association_name_attributes = { :activity_period => :unique_title,
                                       :membership_type => :unique_title }

      @title =  t('memberships.edit.title',
                  :title => @membership.virtual_title)

      render :edit
    end

end
