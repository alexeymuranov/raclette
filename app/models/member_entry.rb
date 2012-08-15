## encoding: UTF-8

class MemberEntry < ActiveRecord::Base

  attr_readonly :id, :member_id

  # Associations:
  has_one :event_entry, :as        => :participant_entry,
                        :dependent => :nullify

  belongs_to :member, :inverse_of => :member_entries

  accepts_nested_attributes_for :event_entry

  # Validations:
  validates :member_id, :guests_invited, :tickets_used,
            :presence => true

  validates :guests_invited, :inclusion => 0..10

  validates :tickets_used, :inclusion => 0..100
end

# == Schema Information
#
# Table name: member_entries
#
#  id             :integer          not null, primary key
#  member_id      :integer          not null
#  guests_invited :integer          default(0)
#  tickets_used   :integer          default(0), not null
#  created_at     :datetime
#  updated_at     :datetime
#

