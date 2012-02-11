## encoding: UTF-8

require 'app_validations/email_format'

class Person < ActiveRecord::Base

  include AbstractSmarterModel

  attr_readonly :id, :last_name

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

  # Public class methods
  def self.sql_for_attributes  # Extendes the one in AbstractSmarterModel
    unless @sql_for_attributes
      super

      full_name_sql         =  "(#{super[:name_title]} || ' ' || "\
                               "#{super[:first_name]} || ' ' || "\
                               "#{super[:last_name]})"

      ordered_full_name_sql = "(UPPER(#{super[:last_name]}) || ', ' || "\
                              "#{super[:first_name]} || ', ' || "\
                              "#{super[:name_title]})"

      formatted_email_sql   = "(#{full_name_sql} || "\
                              "' <' || #{super[:email]} || '>')"

      @sql_for_attributes.merge!(
          :full_name         => full_name_sql,
          :ordered_full_name => ordered_full_name_sql,
          :formatted_email   => formatted_email_sql )
    end
    @sql_for_attributes
  end

  def self.attribute_db_types  # Extendes the one in AbstractSmarterModel
    unless @attribute_db_types
      super

      [ :full_name, :ordered_full_name, :formatted_email ].each do |attr|
        @attribute_db_types[attr] = :virtual_string
      end
    end
    @attribute_db_types
  end

  # Scopes
  scope :default_order, order("UPPER(#{sql_for_attributes[:last_name]}) ASC, "\
                              "UPPER(#{sql_for_attributes[:first_name]}) ASC")

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
# == Schema Information
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

