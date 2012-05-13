## encoding: UTF-8

class RevenueAccount < ActiveRecord::Base

  attr_readonly :id, :opened_on

  # Associations:
  has_many :payments, :dependent  => :nullify,
                      :inverse_of => :revenue_account
  
  belongs_to :activity_period, :inverse_of => :revenue_accounts

  # Validations:
  validates :unique_title, :opened_on, :amount, :amount_updated_on,
            :presence => true

  validates :unique_title, :length => 1..64

  validates :description, :length    => { :maximum => 255 },
                          :allow_nil => true

  validates :unique_title, :uniqueness => { :case_sensitive => false }
end
# == Schema Information
#
# Table name: revenue_accounts
#
#  id                 :integer         not null, primary key
#  unique_title       :string(64)      not null
#  locked             :boolean         default(FALSE), not null
#  activity_period_id :integer
#  opened_on          :date
#  closed_on          :date
#  main               :boolean         default(FALSE), not null
#  amount             :decimal(7, 2)   default(0.0), not null
#  amount_updated_on  :date
#  description        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

