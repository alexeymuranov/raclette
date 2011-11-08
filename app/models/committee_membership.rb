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

  # Scopes:
  scope :default_order, order('end_date DESC, start_date DESC')
end
# == Schema Information
#
# Table name: committee_memberships
#
#  id         :integer         not null, primary key
#  person_id  :integer         not null
#  function   :string(64)      not null
#  start_date :date            not null
#  end_date   :date
#  quit       :boolean         default(FALSE), not null
#  comment    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

