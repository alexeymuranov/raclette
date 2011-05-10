class Event < ActiveRecord::Base

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
