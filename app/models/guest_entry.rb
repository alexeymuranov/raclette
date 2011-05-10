class GuestEntry < ActiveRecord::Base

  attr_readonly :id, :first_name

  # attr_accessible( # :id,
                   # :first_name,
                   # :last_name,
                   # :inviting_member_id,
                   # :previous_entry_id,
                   # :toward_membership_purchase_id,
                   # :email,
                   # :phone,
                   # :note
                 # )  ## all attributes listed here

  has_one :event_entry, :as        => :participant_entry,
                        :dependent => :nullify

  has_one :following_entry, :foreign_key => :previous_entry_id,
                            :class_name  => :GuestEntry,
                            :dependent   => :nullify,
                            :inverse_of  => :previous_entry

  has_many :following_event_entry_reservations,
               :foreign_key => :previous_guest_entry_id,
               :class_name  => :EventEntryReservation,
               :dependent   => :nullify,
               :inverse_of  => :previous_guest_entry

  belongs_to :previous_entry, :class_name => :GuestEntry,
                              :inverse_of => :following_entry

  belongs_to :membership_purchase,
                 :foreign_key => :toward_membership_purchase_id,
                 :inverse_of  => :accounted_guest_entries
end
