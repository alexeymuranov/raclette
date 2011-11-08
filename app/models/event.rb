## encoding: UTF-8

class Event < ActiveRecord::Base

  attr_readonly :id, :event_type, :lesson, :weekly

  # attr_accessible( # :id,
                   # :event_type,
                   # :title,
                   # :locked,
                   # :lesson,
                   # :date,
                   # :start_time,
                   # :duration_minutes,
                   # :end_time,
                   # :location,
                   # :address_id,
                   # :weekly,
                   # :weekly_event_id,
                   # :supervisors,
                   # :lesson_supervision_id,
                   # :entry_fee_tickets,
                   # :member_entry_fee,
                   # :couple_entry_fee,
                   # :common_entry_fee,
                   # :over,
                   # :reservations_count,
                   # :entries_count,
                   # :member_entries_count,
                   # :tickets_collected,
                   # :entry_fees_collected,
                   # :description
                 # )  ## all attributes listed here

  # Associations:
  has_many :event_entry_reservations, :dependent  => :nullify,
                                      :inverse_of => :event

  has_many :event_entries, :dependent  => :nullify,
                           :inverse_of => :event

  has_many :cashiers, :class_name => 'EventCashier',
                      :dependent  => :nullify,
                      :inverse_of => :event

  belongs_to :address, :inverse_of => :events

  belongs_to :weekly_event, :inverse_of => :events

  belongs_to :lesson_supervision, :inverse_of => :events

  # Validations:
  validates :event_type, :presence => true

  validates :event_type, :length    => { :maximum => 32 },
                         :inclusion => %w[ Cours
                                           Atelier
                                           Practica
                                           SoiréeSpécial
                                           Initiation ]

  validates :title, :location,
                :length    => { :maximum => 64 },
                :allow_nil => true

  validates :start_time, :end_time,
                :length    => { :maximum => 8 },
                :allow_nil => true

  validates :duration_minutes, :inclusion => 5..(24*60),
                               :allow_nil => true

  validates :supervisors, :length    => { :maximum => 255 },
                          :allow_nil => true

  validates :entry_fee_tickets, :inclusion => 0..100,
                                :allow_nil => true

  validates :member_entry_fee, :couple_entry_fee, :common_entry_fee,
                :numericality => { :greater_than_or_equal_to => 0 },
                :allow_nil    => true

  validates :entries_count, :member_entries_count,
                :inclusion => 0..10000,
                :allow_nil => true

  validates :tickets_collected,
                :numericality => { :greater_than_or_equal_to => 0 },
                :allow_nil    => true

  validates :entry_fees_collected,
                :numericality => { :greater_than_or_equal_to => 0 },
                :allow_nil    => true

  validates :description, :length    => { :maximum => 255 },
                          :allow_nil => true

  # Scopes:
  scope :default_order, order('date DESC, end_time DESC, start_time DESC')
end
# == Schema Information
#
# Table name: events
#
#  id                    :integer         not null, primary key
#  event_type            :string(32)      not null
#  title                 :string(64)
#  locked                :boolean         default(FALSE), not null
#  lesson                :boolean         not null
#  date                  :date
#  start_time            :string(8)
#  duration_minutes      :integer(2)
#  end_time              :string(8)
#  location              :string(64)
#  address_id            :integer
#  weekly                :boolean         default(FALSE), not null
#  weekly_event_id       :integer
#  supervisors           :string(255)
#  lesson_supervision_id :integer
#  entry_fee_tickets     :integer(1)
#  member_entry_fee      :decimal(3, 1)
#  couple_entry_fee      :decimal(3, 1)
#  common_entry_fee      :decimal(3, 1)
#  over                  :boolean         default(FALSE), not null
#  reservations_count    :integer(2)      default(0)
#  entries_count         :integer(2)      default(0)
#  member_entries_count  :integer(2)      default(0)
#  tickets_collected     :integer(2)      default(0)
#  entry_fees_collected  :decimal(6, 1)   default(0.0)
#  description           :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

