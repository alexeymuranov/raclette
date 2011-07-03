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

  # attr_accessible( # :id,
                   # :person_id,
                   # :been_member_by,
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
                   # :free_tickets_count
                 # )  ## all attributes listed here

  # Associations:
  has_one :tickets_lender, :foreign_key => :shares_tickets_with_member_id,
                           :class_name  => :Member,
                           :dependent   => :nullify,
                           :inverse_of  => :tickets_borrower

  has_one :short_history, :class_name => :MemberShortHistory,
                          :dependent  => :destroy,
                          :inverse_of => :member

  has_many :statistic_counters, :class_name => :MemberStatisticCounter,
                                :dependent  => :destroy,
                                :inverse_of => :member

  has_many :event_entry_reservations, :dependent  => :nullify,
                                      :inverse_of => :member

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
                 :class_name  => :Member,
                 :inverse_of  => :tickets_lender

  accepts_nested_attributes_for :person

  # Validations:
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
end
