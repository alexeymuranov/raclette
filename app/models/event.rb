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
end
