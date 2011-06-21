## encoding: UTF-8

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

  # Associations:
  has_many :weekly_event_suspensions, :dependent  => :destroy,
                                      :inverse_of => :weekly_event

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :weekly_event

  belongs_to :lesson_supervision, :inverse_of => :weekly_events

  belongs_to :address, :inverse_of => :weekly_events

  # Validations:
  validates :event_type, :title, :start_on, :week_day,
                :presence => true

  validates :event_type, :length    => { :maximum => 32 },
                         :inclusion => %w[ Cours
                                           Atelier
                                           Practica
                                           SoiréeSpécial
                                           Initiation ]

  validates :title, :length    => { :maximum => 64 },
                    :allow_nil => true

  validates :start_time, :end_time,
                :length    => { :maximum => 8 },
                :allow_nil => true

  validates :duration_minutes, :inclusion => 5..(24*60),
                               :allow_nil => true

  validates :location, :length    => { :maximum => 64 },
                       :allow_nil => true

  validates :entry_fee_tickets, :inclusion => 0..100,
                                :allow_nil => true

  validates :description, :length    => { :maximum => 255 },
                          :allow_nil => true

  validates :start_on, :end_on,
                :uniqueness => { :scope => :title }
end
