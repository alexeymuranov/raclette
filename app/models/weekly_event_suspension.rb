class WeeklyEventSuspension < ActiveRecord::Base

  belongs_to :weekly_event, :inverse_of => :weekly_event_suspensions
end
