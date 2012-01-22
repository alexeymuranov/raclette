## encoding: UTF-8

class PersonalStatement < ActiveRecord::Base
  self.primary_key = 'person_id'

  attr_readonly :id, :person_id

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
# == Schema Information
#
# Table name: personal_statements
#
#  person_id                  :integer         not null, primary key
#  birthday                   :date
#  accept_email_announcements :boolean         default(FALSE)
#  volunteer                  :boolean         default(FALSE)
#  volunteer_as               :string(255)
#  preferred_language         :string(32)
#  occupation                 :string(64)
#  remark                     :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#

