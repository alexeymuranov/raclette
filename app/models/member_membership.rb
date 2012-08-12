## encoding: UTF-8

class MemberMembership < ActiveRecord::Base

  attr_readonly :id, :member_id, :membership_id, :obtained_on

  # Associations:
  belongs_to :member, :inverse_of => :member_memberships

  belongs_to :membership, :inverse_of    => :member_memberships,
                          :counter_cache => :members_count

  # Validations:
  validates :member_id, :membership_id, :obtained_on,
            :presence => true

  validates :membership_id, :uniqueness => { :scope => :member_id }
end

# == Schema Information
#
# Table name: member_memberships
#
#  id            :integer          not null, primary key
#  member_id     :integer          not null
#  membership_id :integer          not null
#  obtained_on   :date             not null
#  created_at    :datetime
#  updated_at    :datetime
#

