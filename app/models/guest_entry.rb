## encoding: UTF-8

class GuestEntry < ActiveRecord::Base

  attr_readonly :id, :first_name

  # Associations:
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

  # Validations:
  validates :first_name, :presence => true

  validates :first_name, :length => { :maximum => 32 }

  validates :last_name, :phone,
                :length    => { :maximum => 32 },
                :allow_nil => true

  validates :email, :length       => { :maximum => 255 },
                    :email_format => true,
                    :allow_nil    => true

  validates :note, :length    => { :maximum => 255 },
                   :allow_nil => true

  validates :previous_entry_id, :uniqueness => true,
                                :allow_nil  => true
end
# == Schema Information
#
# Table name: guest_entries
#
#  id                            :integer         not null, primary key
#  first_name                    :string(32)      not null
#  last_name                     :string(32)
#  inviting_member_id            :integer
#  previous_entry_id             :integer
#  toward_membership_purchase_id :integer
#  email                         :string(255)
#  phone                         :string(32)
#  note                          :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#

