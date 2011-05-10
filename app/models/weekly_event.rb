class WeeklyEvent < ActiveRecord::Base

  has_many :weekly_event_suspensions, :dependent  => :destroy,
                                      :inverse_of => :weekly_event

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :weekly_event

  belongs_to :lesson_supervision, :inverse_of => :weekly_events

  belongs_to :address, :inverse_of => :weekly_events
end
