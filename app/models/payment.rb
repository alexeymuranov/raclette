## encoding: UTF-8

class Payment < ActiveRecord::Base

  attr_readonly :id, :payable_type, :date, :amount, :method

  # Associations:
  belongs_to :purchase, :foreign_key => :payable_id,
                        :polymorphic => true

  belongs_to :revenue_account, :inverse_of  => :payments

  belongs_to :payer, :foreign_key => :payer_person_id,
                     :class_name  => 'Person',
                     :inverse_of  => :payments

  # Validations:
  validates :payable_type, :date, :amount, :method,
                :presence => true

  validates :payable_type, :length => { :maximum => 32 }

  validates :amount,
                :numericality => { :greater_than_or_equal_to => 0 }

  validates :method, :length    => { :maximum => 32 },
                     :inclusion => %w[ Cash Check CreditCard ]

  validates :note, :length    => { :maximum => 255 },
                   :allow_nil => true

  validates :payable_id, :uniqueness => { :scope => :payable_type },
                         :allow_nil  => true
end
# == Schema Information
#
# Table name: payments
#
#  id                       :integer         not null, primary key
#  payable_type             :string(32)      not null
#  payable_id               :integer
#  date                     :date            not null
#  amount                   :decimal(4, 1)   not null
#  method                   :string(32)      not null
#  revenue_account_id       :integer
#  payer_person_id          :integer
#  cancelled_and_reimbursed :boolean         default(FALSE), not null
#  cancelled_on             :date
#  note                     :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#

