class MemberMembership < ActiveRecord::Base

  belongs_to :member, :inverse_of => :member_memberships

  belongs_to :membership, :inverse_of => :member_memberships
end
