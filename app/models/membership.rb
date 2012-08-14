## encoding: UTF-8

require 'app_active_record_extensions/pseudo_columns'

class Membership < ActiveRecord::Base

  include PseudoColumns
  include AbstractHumanizedModel

  attr_readonly :id, :membership_type_id, :activity_period_id, :initial_price

  # Associations:
  has_many :member_memberships, :dependent  => :nullify,
                                :inverse_of => :membership

  has_many :members, :through => :member_memberships

  has_many :membership_purchases, :dependent  => :nullify,
                                  :inverse_of => :membership

  belongs_to :activity_period, :inverse_of => :memberships

  belongs_to :type, :foreign_key => :membership_type_id,
                    :class_name  => 'MembershipType',
                    :inverse_of  => :memberships

  # Validations:
  validates :membership_type_id, :activity_period_id, :initial_price,
                :presence => true

  validates :initial_price, :numericality => { :greater_than_or_equal_to => 0 }

  validates :current_price, :tickets_count_limit, :members_count,
                :numericality => { :greater_than_or_equal_to => 0 },
                :allow_nil    => true

  validates :membership_type_id,
                :uniqueness => { :scope => :activity_period_id }

  # Delegations:
  delegate :start_date,
           :duration_months,
           :end_date,
           :to => :activity_period

  # Scopes:
  scope :with_type,
        joins('INNER JOIN membership_types ON '\
              'membership_types.id = memberships.membership_type_id')
  scope :with_activity_period,
        joins('INNER JOIN activity_periods ON '\
              'activity_periods.id = memberships.activity_period_id')
  # The following does not work when used with `merge` from another model
  # (see GitHub rails Issue #5494):
  # scope :with_activity_period, joins(:activity_period)
  scope :reverse_order_by_expiration_date,
        with_activity_period.merge(ActivityPeriod.reverse_order_by_end_date)
  scope :default_order, reverse_order_by_expiration_date
  scope :current, with_activity_period.merge(ActivityPeriod.current)

  # default_scope with_type.with_activity_period # FIXME

  # Pseudo columns

  [:start_date, :duration_months, :end_date].each do |attr|
    add_pseudo_columns attr => ActivityPeriod.sql_for_columns[attr]
  end

  add_pseudo_columns :type_title => MembershipType.sql_for_columns[:unique_title]

  title_sql = "(#{ sql_for_columns[:type_title] } || "\
              "', ' || "\
              "#{ sql_for_columns[:start_date] } || "\
              "' -- ' || "\
              "#{ sql_for_columns[:end_date] })"
  add_pseudo_columns :title => title_sql

  add_pseudo_column_db_types  :start_date      => :date,
                                    :duration_months => :integer,
                                    :end_date        => :date,
                                    :type_title      => :string,
                                    :title           => :string
end

# == Schema Information
#
# Table name: memberships
#
#  id                  :integer          not null, primary key
#  membership_type_id  :integer          not null
#  activity_period_id  :integer          not null
#  initial_price       :decimal(4, 1)
#  current_price       :decimal(4, 1)
#  tickets_count_limit :integer
#  members_count       :integer          default(0)
#  created_at          :datetime
#  updated_at          :datetime
#

