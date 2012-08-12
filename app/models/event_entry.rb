## encoding: UTF-8

class EventEntry < ActiveRecord::Base

  attr_readonly :id, :participant_entry_type

  # Associations:
  has_one :payment, :as        => :payable,
                    :dependent => :nullify

  belongs_to :person, :inverse_of => :event_entries

  belongs_to :event, :inverse_of => :event_entries

  belongs_to :participant_entry, :polymorphic => true,
                                 :dependent   => :destroy

  # Validations:
  validates :event_id, :presence  => true

  validates :participant_entry_type, :presence  => true,
                                     :length    => { :maximum => 32 },
                                     :inclusion => %w[MemberEntry GuestEntry]

  validates :participant_entry_id,
            :uniqueness => { :scope => :participant_entry_type },
            :allow_nil  => true

  validates :person_id, :uniqueness => { :scope => :event_id },
                        :allow_nil  => true
end

# == Schema Information
#
# Table name: event_entries
#
#  id                     :integer          not null, primary key
#  participant_entry_type :string(32)       not null
#  participant_entry_id   :integer
#  event_id               :integer          not null
#  person_id              :integer
#  created_at             :datetime
#  updated_at             :datetime
#  validated_by_user      :string(32)
#

