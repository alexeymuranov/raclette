## encoding: UTF-8

class Instructor < ActiveRecord::Base
  self.primary_key = 'person_id'

  attr_readonly :id, :person_id

  # Associations
  has_many :lesson_instructors, :dependent  => :destroy,
                                :inverse_of => :instructor

  has_many :lesson_supervisons, :through => :lesson_instructors

  belongs_to :person, :inverse_of => :instructor

  accepts_nested_attributes_for :person

  # Delegations
  delegate :last_name,
           :first_name,
           :name_title,
           :nickname_or_other,
           :full_name,
           :birthyear,
           :email,
           :mobile_phone,
           :home_phone,
           :work_phone,
           :personal_phone,
           :primary_address,
           :to => :person

  # Validations
  validates :person_id, :presence => true

  validates :presentation, :length    => { :maximum => 32*1024 },
                           :allow_nil => true

  validates :photo, :length    => { :maximum => 2.megabytes },
                    :allow_nil => true

  validates :person_id, :uniqueness => true

  # Scopes
  scope :default_order, joins(:person).order('person.last_name ASC')
end
# == Schema Information
#
# Table name: instructors
#
#  person_id      :integer         not null, primary key
#  presentation   :text
#  photo          :binary
#  employed_from  :date
#  employed_until :date
#  created_at     :datetime
#  updated_at     :datetime
#

