class WeeklyEventSuspension < ActiveRecord::Base

  attr_readonly :id, :weekly_event_id, :suspend_from

  # attr_accessible( # :id,
                   # :weekly_event_id,
                   # :suspend_from,
                   # :suspend_until,
                   # :explanation
                 # )  ## all attributes listed here

  # Associations:
  belongs_to :weekly_event, :inverse_of => :weekly_event_suspensions

  # Validations:
  validates :weekly_event_id, :suspend_from, :suspend_until,
                :presence => true

  validates :explanation, :length    => { :maximum => 255 },
                          :allow_nil => true

  validates :suspend_from, :suspend_until,
                :uniqueness => { :scope => :weekly_event_id }
end
