## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'

class Instructor < ActiveRecord::Base
  self.primary_key = 'person_id'

  include Filtering
  include Sorting
  self.default_sorting_column = :ordered_full_name

  include AbstractPerson
  include AbstractHumanizedModel

  attr_readonly :id, :person_id

  # Associations
  has_many :lesson_instructors, :dependent  => :destroy,
                                :inverse_of => :instructor

  has_many :lesson_supervisions, :through => :lesson_instructors

  belongs_to :person, :inverse_of => :instructor

  accepts_nested_attributes_for :person

  # Validations
  validates :person_id, :presence => true

  validates :presentation, :length    => { :maximum => 32*1024 },
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
      nickname_or_other.blank? ? nil : "'#{ nickname_or_other }'",
      last_name ].reject(&:blank?).join(' ')
  end
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

