class EventCashier < ActiveRecord::Base

  attr_readonly :id, :name, :started_at

  # attr_accessible( # :id,
                   # :event_id,
                   # :name,
                   # :person_id,
                   # :started_at,
                   # :finished_at
                 # )  ## all attributes listed here

  belongs_to :event, :inverse_of => :cashiers

  belongs_to :person, :inverse_of => :event_cashiers
end
