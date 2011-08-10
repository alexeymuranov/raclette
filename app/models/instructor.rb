## encoding: UTF-8

# == Schema Information
# Schema version: 20110618120707
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

class Instructor < ActiveRecord::Base
  set_primary_key :person_id

  attr_readonly :id, :person_id

  # attr_accessible( # :id,
                   # :person_id,
                   # :presentation,
                   # :photo,
                   # :employed_from,
                   # :employed_until
                 # )  ## all attributes listed here

  # Associations:
  has_many :lesson_instructors, :dependent  => :destroy,
                                :inverse_of => :instructor

  has_many :lesson_supervisons, :through => :lesson_instructors

  belongs_to :person, :inverse_of => :instructor

  accepts_nested_attributes_for :person

  # Delegations:
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

  # Validations:
  validates :person_id, :presence => true

  validates :presentation, :length    => { :maximum => 32*1024 },
                           :allow_nil => true

  validates :photo, :length    => { :maximum => 2.megabytes },
                    :allow_nil => true

  validates :person_id, :uniqueness => true

  # Scopes:
	scope :default_order, order('person_id DESC')
end
