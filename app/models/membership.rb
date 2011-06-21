## encoding: UTF-8

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
end
