## encoding: UTF-8

# == Schema Information
# Schema version: 20110618120707
#
# Table name: members
#
#  person_id                         :integer         not null, primary key
#  been_member_by                    :date            not null
#  shares_tickets_with_member_id     :integer
#  account_deactivated               :boolean         not null
#  latest_membership_obtained_on     :date
#  latest_membership_expiration_date :date
#  latest_membership_type            :string(32)
#  latest_membership_duration_months :integer(1)      default(12)
#  last_card_printed_on              :date
#  last_card_delivered               :boolean
#  last_payment_date                 :date
#  last_entry_date                   :date
#  payed_tickets_count               :integer(2)      default(0), not null
#  free_tickets_count                :integer(2)      default(0), not null
#  created_at                        :datetime
#  updated_at                        :datetime
#

class Member < ActiveRecord::Base
  set_primary_key :person_id

  attr_readonly :id, :person_id, :been_member_by

  attr_accessible( # :id,
                   # :person_id,
                   :been_member_by,
                   # :shares_tickets_with_member_id,
                   # :account_deactivated,
                   # :latest_membership_obtained_on,
                   # :latest_membership_expiration_date,
                   # :latest_membership_type,
                   # :latest_membership_duration_months,
                   # :last_card_printed_on,
                   # :last_card_delivered,
                   # :last_payment_date,
                   # :last_entry_date,
                   # :payed_tickets_count,
                   :free_tickets_count,
                   :last_name,         # delegated attribute
                   :first_name,        # delegated attribute
                   :name_title,        # delegated attribute
                   :nickname_or_other, # delegated attribute
                   :birthyear,         # delegated attribute
                   :email,             # delegated attribute
                   :mobile_phone,      # delegated attribute
                   :home_phone,        # delegated attribute
                   :work_phone,        # delegated attribute
                   :personal_phone,    # delegated attribute
                   :primary_address,   # delegated attribute
                   :person_attributes  # association attribute
                 )  ## all attributes listed here

  # Associations
  has_one :tickets_lender, :foreign_key => :shares_tickets_with_member_id,
                           :class_name  => 'Member',
                           :dependent   => :nullify,
                           :inverse_of  => :tickets_borrower

  has_one :short_history, :class_name => 'MemberShortHistory',
                          :dependent  => :destroy,
                          :inverse_of => :member

  # has_many :statistic_counters, :class_name => 'MemberStatisticCounter',
  #                               :dependent  => :destroy,
  #                               :inverse_of => :member

  # has_many :event_entry_reservations, :dependent  => :nullify,
  #                                     :inverse_of => :member

  has_one :member_message, :dependent  => :destroy,
                           :inverse_of => :member

  has_many :member_memberships, :dependent  => :destroy,
                                :inverse_of => :member

  has_many :memberships, :through => :member_memberships

  has_many :membership_purchases, :dependent  => :destroy,
                                  :inverse_of => :member

  has_many :tickets_purchases, :dependent  => :destroy,
                               :inverse_of => :member

  has_many :member_entries, :dependent  => :destroy,
                            :inverse_of => :member

  belongs_to :person, :inverse_of => :member

  belongs_to :tickets_borrower,
                 :foreign_key => :shares_tickets_with_member_id,
                 :class_name  => 'Member',
                 :inverse_of  => :tickets_lender

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

  delegate :unique_title, :duration_months,
           :to     => :'current_membership.type',
           :prefix => :current_membership

  delegate :unique_title, :start_date, :duration_months, :end_date,
           :to     => :'current_membership.activity_period',
           :prefix => :current_membership

  # Validations
  validates :person_id, :been_member_by,
            :payed_tickets_count, :free_tickets_count,
                :presence => true

  validates :latest_membership_type, :length    => { :maximum => 32 },
                                     :allow_nil => true

  validates :latest_membership_duration_months, :inclusion => 1..12,
                                                :allow_nil => true

  validates :payed_tickets_count, :inclusion => -100..1000

  validates :free_tickets_count, :inclusion => 0..100

  validates :shares_tickets_with_member_id, :uniqueness => true,
                                            :allow_nil  => true

  validates :person_id, :uniqueness => true

  # Some "static" public class methods
  def self.full_name_sql
    Person.full_name_sql
  end

  def self.ordered_full_name_sql
    Person.ordered_full_name_sql
  end

  def self.formatted_email_sql
    Person.formatted_email_sql
  end

  def self.tickets_count_sql
    "(members.payed_tickets_count + members.free_tickets_count)"
  end

  def self.virtual_sql_attributes
    Person.virtual_sql_attributes + [ :tickets_count ]
  end

  def self.virtual_attributes_in_sql
    @@virtual_attributes_in_sql ||=
        Person.virtual_attributes_in_sql.merge(
            :tickets_count     => self.tickets_count_sql,
            :last_name         => "people.last_name",
            :first_name        => "people.first_name",
            :name_title        => "people.name_title",
            :nickname_or_other => "people.nickname_or_other",
            :email             => "people.email"
          ).with_indifferent_access
  end

  def self.virtual_attributes_sql
    [ Person.virtual_attributes_sql,
      "#{self.tickets_count_sql} AS tickets_count" ].join(', ')
  end

  def virtual_attribute_types(attr)
    @virtual_attribute_types ||= {
        :full_name           => :virtual_string,
        :ordered_full_name   => :virtual_string,
        :email               => :delegated_string,
        :payed_tickets_count => :integer,
        :free_tickets_count  => :integer,
        :tickets_count       => :virtual_integer }
  # NOTE: virtual_ includes "delegated_to_virtual_",
  #       but not "delegated_to_real_".
  #       "delegated_to_real_" is simply delegated_
  end

  # Scopes
  scope :with_person_and_virtual_attributes,
        joins(:person).select("members.*, people.*, #{virtual_attributes_sql}")

  scope :default_order, joins(:person).order('people.last_name ASC, people.first_name ASC')
  scope :account_active, where(:account_deactivated => false)

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
  def non_sql_account_active
    !account_deactivated
  end

  alias_method :'non_sql_account_active?', :non_sql_account_active

  def non_sql_current_membership  # FIXME
    raise "Method not implemented"
    # ???
  end
end
