## encoding: UTF-8

# == Schema Information
# Schema version: 20110618120707
#
# Table name: people
#
#  id                 :integer         not null, primary key
#  last_name          :string(32)      not null
#  first_name         :string(32)      not null
#  name_title         :string(16)
#  nickname_or_other  :string(32)      default(""), not null
#  birthyear          :integer(2)
#  email              :string(255)
#  mobile_phone       :string(32)
#  home_phone         :string(32)
#  work_phone         :string(32)
#  primary_address_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

require 'assets/app_validations/email_format'

class Person < ActiveRecord::Base

  attr_readonly :id, :last_name

  attr_accessible( # :id,
                   :last_name,
                   :first_name,
                   :name_title,
                   :nickname_or_other,
                   # :birthyear
                   :email,
                   # :mobile_phone,
                   # :home_phone,
                   # :work_phone,
                   # :primary_address_id,
                   # :full_name  # virtual attribute
                 )  ## all attributes listed here

  # Associations
  has_many :users, :dependent  => :nullify,
                   :inverse_of => :person

  has_one :statement, :class_name => 'PersonalStatement',
                      :dependent  => :destroy,
                      :inverse_of => :person

  has_one :instructor, :dependent  => :destroy,
                       :inverse_of => :person

  has_many :committee_memberships, :dependent  => :destroy,
                                   :inverse_of => :person

  has_one :member, :dependent  => :destroy,
                   :inverse_of => :person

  has_many :payments, :foreign_key => :payer_person_id,
                      :dependent   => :nullify,
                      :inverse_of  => :payer

  has_many :event_entries, :dependent  => :destroy,
                           :inverse_of => :person

  has_many :event_cashiers, :dependent  => :nullify,
                            :inverse_of => :person

  belongs_to :primary_address, :class_name => 'Address',
                               :inverse_of => :people

  accepts_nested_attributes_for :primary_address, :statement

  # Validations
  validates :last_name, :first_name,
                :presence => true

  validates :last_name, :first_name, :nickname_or_other,
                :length => { :maximum => 32 }

  validates :name_title, :length    => { :maximum => 16 },
                         :allow_nil => true

  validates :birthyear, :inclusion => 1900..2099,
                        :allow_nil => true

  validates :email, :length       => { :maximum => 255 },
                    :email_format => true,
                    :allow_nil    => true

  validates :mobile_phone, :home_phone, :work_phone,
                :length    => { :maximum => 32 },
                :allow_nil => true

  validates :nickname_or_other,
                :uniqueness => { :scope => [ :last_name, :first_name ] }

  # Some "static" public class methods
  def self.full_name_sql
    "(people.name_title || ' ' || people.first_name || ' ' || people.last_name)"
  end

  def self.ordered_full_name_sql
    "(people.last_name || ', ' || people.first_name"\
                     " || ', ' || people.name_title)"
  end

  def self.formatted_email_sql
    "(#{full_name_sql} || ' <' || people.email || '>')"
  end

  def self.virtual_attributes_in_sql
    @@virtual_attributes_in_sql ||= {
        :full_name         => self.full_name_sql,
        :ordered_full_name => self.ordered_full_name_sql,
        :formatted_email   => self.formatted_email_sql
      }.with_indifferent_access
  end

  def self.virtual_sql_attributes
    [ :full_name, :ordered_full_name, :formatted_email ]
  end

  def self.virtual_attributes_sql
    [ "#{self.full_name_sql} AS full_name",
      "#{self.ordered_full_name_sql} AS ordered_full_name",
      "#{self.formatted_email_sql} AS formatted_email" ].join(', ')
  end

  # Scopes
  scope :with_virtual_attributes, select("people.*, #{virtual_attributes_sql}")

  scope :default_order, order('people.last_name ASC, people.first_name ASC')

  # Public class methods
  def self.attribute_to_column_name_or_sql_expression(attr)
    column_as_string = attr.to_s
    if self.column_names.include?(column_as_string)
      [ self.table_name, column_as_string ].join('.')
    else
      self.virtual_attributes_in_sql[attr]
    end
  end

  # Public instance methods
  # Non-SQL virtual attributes
  def non_sql_full_name
    [ name_title,
      first_name,
      nickname_or_other.blank? ? nil : "'#{nickname_or_other}'",
      last_name ].reject(&:blank?).join(' ')
  end

  def non_sql_personal_phone
    mobile_phone || home_phone
  end
end
