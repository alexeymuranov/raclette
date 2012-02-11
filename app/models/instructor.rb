## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'

class Instructor < ActiveRecord::Base
  include Filtering
  include Sorting
  self.default_sorting_column = :ordered_full_name
  self.all_sorting_columns = []

  self.primary_key = 'person_id'

  include AbstractPerson # TODO: take advatage of AbstractPerson here instead of AbstractSmarterModel

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
           :birthyear,
           :email,
           :mobile_phone,
           :home_phone,
           :work_phone,
           :personal_phone,
           :primary_address,
           :non_sql_full_name,
           :to => :person

  # Validations
  validates :person_id, :presence => true

  validates :presentation, :length    => { :maximum => 32*1024 },
                           :allow_nil => true

  validates :photo, :length    => { :maximum => 2.megabytes },
                    :allow_nil => true

  validates :person_id, :uniqueness => true

  # Public class methods

  # @@people_table_name = Person.table_name

  def self.sql_for_attributes  # Extends the one from AbstractSmarterModel
    unless @sql_for_attributes
      super

      [ :last_name, :first_name, :name_title, :nickname_or_other, :email,
        :full_name, :ordered_full_name, :formatted_email ]\
          .each do |attr|
        @sql_for_attributes[attr] = Person.sql_for_attributes[attr]
      end
    end
    @sql_for_attributes
  end

  def self.attribute_db_types  # Extends the one from AbstractSmarterModel
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
  scope :default_order, joins(:person).merge(Person.default_order)
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

