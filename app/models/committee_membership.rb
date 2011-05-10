class CommitteeMembership < ActiveRecord::Base

  belongs_to :person, :inverse_of => :committee_membership
end
