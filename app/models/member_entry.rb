## encoding: UTF-8

class MemberEntry < ActiveRecord::Base

  attr_readonly :id, :member_id

  # Associations:
  belongs_to :member, :inverse_of => :member_entries

  has_one :event_entry, :as        => :participant_entry,
                        :dependent => :nullify

  accepts_nested_attributes_for :event_entry

  # Validations:
  validates :member_id, :guests_invited, :tickets_used,
            :presence => true

  validates :guests_invited, :inclusion => 0..10

  validates :tickets_used, :inclusion => 0..100

  # Callbacks:
  before_validation :build_event_entry_and_set_person_for_event_entry

  private

    def build_event_entry_and_set_person_for_event_entry
      if event_entry
        event_entry.person = member.person
      else
        self.event_entry = EventEntry.new(:person => member.person)
      end
    end

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

