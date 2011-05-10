class EventCashier < ActiveRecord::Base

  belongs_to :event, :inverse_of => :cashiers

  belongs_to :person, :inverse_of => :event_cashiers
end
