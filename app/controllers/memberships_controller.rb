## encoding: UTF-8

class MembershipsController < ManagerController # FIXME!

  class Membership < Membership
    belongs_to :activity_period, :class_name => :ActivityPeriod,
                                 :inverse_of => :memberships
    belongs_to :type, :foreign_key => :membership_type_id,
                      :class_name  => :MembershipType,
                      :inverse_of  => :memberships
  end

  class MembershipType < MembershipType
    self.all_sorting_columns = [ :unique_title,
                                 :duration_months,
                                 :active,
                                 :reduced,
                                 :unlimited ]
    self.default_sorting_column = :unique_title
  end

  class ActivityPeriod < self::ActivityPeriod
    self.all_sorting_columns = [:ip, :description]
    self.default_sorting_column = :ip
  end

  # param_accessible /.+/
  #param_accessible(Set['membership_type_ids_for_activity_periods'], :only => :update_all)

  def index
    @membership_types = MembershipType.default_order
    @activity_periods = ActivityPeriod.default_order

    # @title = t('memberships.index.title')
  end

  def edit_all
    @membership_types = MembershipType.default_order
    @activity_periods = ActivityPeriod.default_order

    # @title = t('memberships.edit_all.title')
  end

  def update_all
    params[:membership_type_ids_for_activity_periods] ||= {}

    ActivityPeriod.all.each do |activity_period|
      new_membership_type_ids = params[:membership_type_ids_for_activity_periods][activity_period.to_param]
      activity_period.membership_type_ids = new_membership_type_ids
    end

    redirect_to :action => :index
  end
end
