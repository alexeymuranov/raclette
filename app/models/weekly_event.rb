class WeeklyEvent < ActiveRecord::Base

  attr_readonly :id, :event_type, :lesson, :start_on

  # attr_accessible( # :id,
                   # :event_type,
                   # :title,
                   # :lesson,
                   # :week_day,
                   # :start_time,
                   # :duration_minutes,
                   # :end_time,
                   # :start_on,
                   # :end_on,
                   # :location,
                   # :address_id,
                   # :lesson_supervision_id,
                   # :entry_fee_tickets,
                   # :over,
                   # :description
                 # )  ## all attributes listed here

  has_many :weekly_event_suspensions, :dependent  => :destroy,
                                      :inverse_of => :weekly_event

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :weekly_event

  belongs_to :lesson_supervision, :inverse_of => :weekly_events

  belongs_to :address, :inverse_of => :weekly_events
end
