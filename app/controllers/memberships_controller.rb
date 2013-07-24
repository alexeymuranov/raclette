## encoding: UTF-8

class MembershipsController < ManagerController

  def index
    @membership_types = MembershipType.default_order
    @activity_periods = ActivityPeriod.default_order
  end

  def show
    @membership = Membership.find(params['id'])

    @attribute_names = [:initial_price, :current_price]

    @singular_association_names = [:activity_period, :membership_type]
    @association_name_attributes = { :activity_period => :unique_title,
                                     :membership_type => :unique_title }

    @ticket_book_attribute_names = [:tickets_number, :price]

    @ticket_books = @membership.ticket_books
    # @ticket_books_column_headers = TicketBook.human_column_headers

    # Sort:
    sort_params = (params[:sort] && params[:sort][:ticket_books]) || {}
    @ticket_books = sort(@ticket_books, sort_params, :tickets_number)

    @title = t('memberships.show.title',
               :title => @membership.virtual_title)
  end

  def new
    attributes = process_raw_membership_attributes_for_new
    @membership = Membership.new(attributes)

    render_new_properly
  end

  def edit
    @membership = Membership.find(params['id'])

    render_edit_properly
  end

  def create
    attributes = process_raw_membership_attributes_for_create
    @membership = Membership.new(attributes)

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
    @membership = Membership.find(params['id'])

    attributes = process_raw_membership_attributes_for_update

    if @membership.update_attributes(attributes)
      flash[:notice] = t('flash.memberships.update.success',
                         :title => @membership.virtual_title)
      redirect_to :action => :show, :id => @membership
    else
      flash.now[:error] = t('flash.memberships.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @membership = Membership.find(params['id'])

    @membership.destroy

    flash[:notice] = t('flash.memberships.destroy.success',
                       :title => @membership.virtual_title)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @attribute_names = [:initial_price, :current_price]

      @belongs_to_association_names = [:activity_period, :membership_type]
      @association_name_attributes = { :activity_period => :unique_title,
                                       :membership_type => :unique_title }

      @title = t('memberships.new.virtual_title')

      render :new
    end

    def render_edit_properly
      @attribute_names = [:initial_price, :current_price]

      @belongs_to_association_names = [:activity_period, :membership_type]
      @association_name_attributes = { :activity_period => :unique_title,
                                       :membership_type => :unique_title }

      @title = t('memberships.edit.title',
                 :title => @membership.virtual_title)

      render :edit
    end

  module AttributesFromParamsForNew
    MEMBERSHIP_ASSOCIATION_ID_ATTRIBUTE_NAMES =
      [:activity_period_id, :membership_type_id]

    private

      def process_raw_membership_attributes_for_new(
            submitted_attributes =
              params.slice('activity_period_id', 'membership_type_id'))
        MEMBERSHIP_ASSOCIATION_ID_ATTRIBUTE_NAMES.reduce({}) do |attributes, id_attribute_name|
          attributes[id_attribute_name] =
            submitted_attributes[id_attribute_name.to_s].to_i
          attributes
        end
      end

  end
  include AttributesFromParamsForNew


  module AttributesFromParamsForCreate
    MEMBERSHIP_ATTRIBUTE_NAMES = Set[ :activity_period_id,
                                      :membership_type_id,
                                      :initial_price,
                                      :current_price ]
    MEMBERSHIP_ATTRIBUTE_NAMES_FROM_STRINGS =
      MEMBERSHIP_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def membership_attribute_name_from_params_key_for_create(params_key)
        MEMBERSHIP_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_membership_attributes_for_create(
            submitted_attributes = params['membership_type'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [membership_attribute_name_from_params_key_for_create(key), value]
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
    MEMBERSHIP_ATTRIBUTE_NAMES = Set[:current_price]
    MEMBERSHIP_ATTRIBUTE_NAMES_FROM_STRINGS =
      MEMBERSHIP_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def membership_attribute_name_from_params_key_for_update(params_key)
        MEMBERSHIP_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_membership_attributes_for_update(
            submitted_attributes = params['membership_type'])
        attributes_in_array = submitted_attributes.map { |key, value|
          [membership_attribute_name_from_params_key_for_update(key), value]
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
