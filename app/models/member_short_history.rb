## encoding: UTF-8

# == Schema Information
# Schema version: 20110618120707
#
# Table name: member_short_histories
#
#  member_id                              :integer         not null, primary key
#  last_active_membership_expiration_date :date
#  prev_membership_expiration_date        :date            not null
#  prev_membership_type                   :string(32)      not null
#  prev_membership_duration_months        :integer(1)      default(12), not null
#  created_at                             :datetime
#  updated_at                             :datetime
#

class MemberShortHistory < ActiveRecord::Base
  set_primary_key :member_id

  attr_readonly :id, :member_id

  # attr_accessible( # :id,
                   # :member_id,
                   # :last_active_membership_expiration_date,
                   # :prev_membership_expiration_date,
                   # :prev_membership_type,
                   # :prev_membership_duration_months
                 # )  ## all attributes listed here

  # Associations:
  belongs_to :member, :inverse_of => :short_history

  # Validations:
  validates :member_id, :prev_membership_expiration_date,
            :prev_membership_type, :prev_membership_duration_months,
                :presence => true

  validates :prev_membership_type, :length    => { :maximum => 32 },
                                   :allow_nil => true

  validates :prev_membership_duration_months, :inclusion => 1..12,
                                              :allow_nil => true

  validates :member_id, :uniqueness => true
end
