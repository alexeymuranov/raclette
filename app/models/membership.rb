## encoding: UTF-8

# == Schema Information
# Schema version: 20110618120707
#
# Table name: memberships
#
#  id                  :integer         not null, primary key
#  membership_type_id  :integer         not null
#  activity_period_id  :integer         not null
#  initial_price       :decimal(4, 1)
#  current_price       :decimal(4, 1)
#  tickets_count_limit :integer
#  members_count       :integer         default(0)
#  created_at          :datetime
#  updated_at          :datetime
#

class Membership < ActiveRecord::Base

  attr_readonly :id, :membership_type_id, :activity_period_id, :initial_price

  # attr_accessible( # :id,
                   # :membership_type_id,
                   # :activity_period_id,
                   # :initial_price,
                   # :current_price,
                   # :tickets_count_limit,
                   # :members_count
                 # )  ## all attributes listed here

  # Associations:
  has_many :member_memberships, :dependent  => :nullify,
                                :inverse_of => :membership

  has_many :members, :through => :member_memberships

  has_many :membership_purchases, :dependent  => :nullify,
                                  :inverse_of => :membership

  belongs_to :activity_period, :inverse_of => :memberships

  belongs_to :type, :foreign_key => :membership_type_id,
                    :class_name  => :MembershipType,
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
  scope :default_order, order('activity_period_id DESC')
end
