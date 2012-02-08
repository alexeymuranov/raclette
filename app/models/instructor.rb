## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'

class Instructor < AbstractSmarterModel
  extend Filtering
  extend Sorting
  self.default_sorting_column = :ordered_full_name
  self.all_sorting_columns = []

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

  # Public class methods
  def self.sql_for_attributes  # Extendes the one from AbstractSmarterModel
    unless @sql_for_attributes
      super

      people_table_name = Person.table_name

      [ :last_name, :first_name, :name_title, :nickname_or_other, :email,
        :full_name, :ordered_full_name, :formatted_email ]\
          .each do |attr|
        @sql_for_attributes[attr] = Person.sql_for_attributes[attr]
      end
    end
    @sql_for_attributes
  end

  def self.attribute_db_types  # Extendes the one from AbstractSmarterModel
    unless @attribute_db_types
      super

      [ :last_name, :first_name, :name_title, :nickname_or_other, :email]\
          .each do |attr|
        @attribute_db_types[attr] = ('delegated_' +
                                     Person.columns_hash[attr.to_s].type.to_s)\
                                    .to_sym
      end

      [ :full_name, :ordered_full_name, :formatted_email ].each do |attr|
        @attribute_db_types[attr] = :virtual_string
      end
    end
    @attribute_db_types
  end

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

