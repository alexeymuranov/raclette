class MemberMembership < ActiveRecord::Base

  attr_readonly :id, :member_id, :membership_id, :obtained_on

  # attr_accessible( # :id,
                   # :member_id,
                   # :membership_id,
                   # :obtained_on
                 # )  ## all attributes listed here

  belongs_to :member, :inverse_of => :member_memberships

  belongs_to :membership, :inverse_of => :member_memberships
end
