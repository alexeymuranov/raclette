class Membership < ActiveRecord::Base

  has_many :member_memberships, :dependent  => :nullify,
                                :inverse_of => :membership

  has_many :members, :through => :member_memberships

  has_many :membership_purchases, :dependent  => :nullify,
                                  :inverse_of => :membership

  belongs_to :activity_period, :inverse_of => :memberships

  belongs_to :type, :foreign_key => :membership_type_id,
                    :class_name  => :MembershipType,
                    :inverse_of  => :memberships
end
