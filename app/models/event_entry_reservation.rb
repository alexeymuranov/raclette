## encoding: UTF-8

class EventEntryReservation < ActiveRecord::Base

  attr_readonly :id, :event_id

  # Associations:
  belongs_to :event, :inverse_of => :event_entry_reservations

  belongs_to :member, :inverse_of => :event_entry_reservations

  belongs_to :previous_guest_entry,
             :class_name => 'GuestEntry',
             :inverse_of => :following_event_entry_reservations

  # Validations:
  validates :event_id, :people_number, :names, :amount_payed,
                :presence => true

  validates :people_number, :inclusion => 0..10

  validates :names, :length => { :maximum => 64 }

  validates :contact_email, :length    => { :maximum => 64 },
                            :allow_nil => true

  validates :contact_phone, :length    => { :maximum => 32 },
                            :allow_nil => true

  validates :amount_payed, :numericality => { :greater_than_or_equal_to => 0 }

  validates :note, :length    => { :maximum => 255 },
                   :allow_nil => true

  validates :names, :member_id, :previous_guest_entry_id,
                    :uniqueness => { :scope => :event_id },
                    :allow_nil  => true
end

# == Schema Information
#
# Table name: event_entry_reservations
#
#  id                      :integer          not null, primary key
#  event_id                :integer          not null
#  people_number           :integer          default(1), not null
#  names                   :string(64)       not null
#  member_id               :integer
#  previous_guest_entry_id :integer
#  contact_email           :string(255)
#  contact_phone           :string(32)
#  amount_payed            :decimal(3, 1)    default(0.0), not null
#  cancelled               :boolean          default(FALSE), not null
#  note                    :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

