class Member < ActiveRecord::Base
  set_primary_key :person_id

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
end
