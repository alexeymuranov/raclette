## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'

class Member < ActiveRecord::Base
  include Filtering
  include Sorting
  self.default_sorting_column = :ordered_full_name
  self.all_sorting_columns = []

  self.primary_key = 'person_id'

  include AbstractPerson # TODO: take advatage of AbstractPerson here instead of AbstractSmarterModel

  attr_readonly :id, :person_id, :been_member_by

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

  # delegate :unique_title, :duration_months,  # FIXME
  #          :to     => :'current_membership.type',
  #          :prefix => :current_membership

  # delegate :unique_title, :start_date, :duration_months, :end_date,  # FIXME
  #          :to     => :'current_membership.activity_period',
  #          :prefix => :current_membership

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

      tickets_count_sql = "(#{super[:payed_tickets_count]} + "\
                           "#{super[:free_tickets_count]})"

      @sql_for_attributes.merge!(:tickets_count => tickets_count_sql)
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

      @attribute_db_types.merge!(:tickets_count => :virtual_integer)
    end
    @attribute_db_types
  end

  # Scopes
  scope :default_order, joins(:person).merge(Person.default_order)
  scope :account_active, where(:account_deactivated => false)

  # Public instance methods
  # Non-SQL virtual attributes
  def non_sql_account_active
    !account_deactivated
  end

  def non_sql_current_membership  # FIXME
    raise "Method not implemented"
    # ???
  end

  alias_method :'non_sql_account_active?', :non_sql_account_active

end
# == Schema Information
#
# Table name: members
#
#  person_id                         :integer         not null, primary key
#  been_member_by                    :date            not null
#  shares_tickets_with_member_id     :integer
#  account_deactivated               :boolean         default(FALSE), not null
#  latest_membership_obtained_on     :date
#  latest_membership_expiration_date :date
#  latest_membership_type            :string(32)
#  latest_membership_duration_months :integer(1)      default(12)
#  last_card_printed_on              :date
#  last_card_delivered               :boolean         default(FALSE)
#  last_payment_date                 :date
#  last_entry_date                   :date
#  payed_tickets_count               :integer(2)      default(0), not null
#  free_tickets_count                :integer(2)      default(0), not null
#  created_at                        :datetime
#  updated_at                        :datetime
#

