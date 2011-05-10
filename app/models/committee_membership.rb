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

  belongs_to :person, :inverse_of => :committee_membership
end
