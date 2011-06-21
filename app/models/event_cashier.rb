## encoding: UTF-8

class EventCashier < ActiveRecord::Base

  attr_readonly :id, :name, :started_at

  # attr_accessible( # :id,
                   # :event_id,
                   # :name,
                   # :person_id,
                   # :started_at,
                   # :finished_at
                 # )  ## all attributes listed here

  # Associations:
  belongs_to :event, :inverse_of => :cashiers

  belongs_to :person, :inverse_of => :event_cashiers

  # Validations:
  validates :name, :started_at,
                :presence => true

  validates :name, :length => { :maximum => 64 }
end
