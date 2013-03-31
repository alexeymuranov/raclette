## encoding: UTF-8

class Instructor < ActiveRecord::Base
  self.primary_key = 'person_id'

  include AbstractPerson
  include AbstractHumanizedModel

  attr_readonly :id, :person_id

  # Associations
  def self.init_associations
    belongs_to :person, :inverse_of => :instructor

    has_many :lesson_instructors, :dependent  => :destroy,
                                  :inverse_of => :instructor

    has_many :lesson_supervisions, :through => :lesson_instructors

    # accepts_nested_attributes_for :person # This is taken care of in `AbstractPerson`
  end

  init_associations

  # Validations
  validates :person_id, :presence => true

  validates :presentation, :length    => { :maximum => 32 * 1024 },
                           :allow_nil => true

  validates :photo, :length    => { :maximum => 2.megabytes },
                    :allow_nil => true

  validates :person_id, :uniqueness => true

  # Scopes
  scope :default_order, joins(:person).merge(Person.default_order)

  # Public instance methods
  # Non-SQL virtual attributes
  def virtual_professional_name
    [ first_name,
      ("'#{ nickname_or_other }'" unless nickname_or_other.blank?),
      last_name
    ].reject(&:blank?).join(' ')
  end
end

# == Schema Information
#
# Table name: instructors
#
#  person_id      :integer          not null, primary key
#  presentation   :text
#  photo          :binary
#  employed_from  :date
#  employed_until :date
#  created_at     :datetime
#  updated_at     :datetime
#

