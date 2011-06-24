## encoding: UTF-8

# == Schema Information
# Schema version: 20110618120707
#
# Table name: personal_statements
#
#  person_id                  :integer         not null, primary key
#  birthday                   :date
#  accept_email_announcements :boolean
#  volunteer                  :boolean
#  volunteer_as               :string(255)
#  preferred_language         :string(32)
#  occupation                 :string(64)
#  remark                     :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#

class PersonalStatement < ActiveRecord::Base
  set_primary_key :person_id

  attr_readonly :id, :person_id

  # attr_accessible( # :id,
                   # :person_id,
                   # :birthday
                   # :accept_email_announcements,
                   # :volunteer,
                   # :volunteer_as,
                   # :preferred_language,
                   # :occupation,
                   # :remark
                 # )  ## all attributes listed here

  # Associations:
  belongs_to :person, :inverse_of => :statement

  # Validations:
  validates :person_id, :presence => true

  validates :volunteer_as, :remark,
                :length    => { :maximum => 255 },
                :allow_nil => true

  validates :preferred_language, :length    => { :maximum => 32 },
                                 :allow_nil => true

  validates :occupation, :length    => { :maximum => 64 },
                         :allow_nil => true

  validates :person_id, :uniqueness => true
end
