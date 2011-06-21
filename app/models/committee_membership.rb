## encoding: UTF-8

class CommitteeMembership < ActiveRecord::Base

  attr_readonly :id, :person_id, :function, :start_date

  # attr_accessible( # :id,
                   # :person_id,
                   # :function,
                   # :start_date,
                   # :end_date,
                   # :quit,
                   # :comment
                 # )  ## all attributes listed here

  # Associations:
  belongs_to :person, :inverse_of => :committee_membership

  # Validations:
  validates :person_id, :function, :start_date,
                :presence => true

  validates :function, :length => 1..64

  validates :comment, :length    => { :maximum => 255 },
                      :allow_nil => true
end
