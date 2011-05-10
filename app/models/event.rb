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

  has_many :cashiers, :class_name => :EventCashier,
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
end
