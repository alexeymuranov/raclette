class WeeklyEventSuspension < ActiveRecord::Base

  attr_readonly :id, :weekly_event_id, :suspend_from

  # attr_accessible( # :id,
                   # :weekly_event_id,
                   # :suspend_from,
                   # :suspend_until,
                   # :explanation
                 # )  ## all attributes listed here

  belongs_to :weekly_event, :inverse_of => :weekly_event_suspensions
end
