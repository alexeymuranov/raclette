## encoding: UTF-8

class RevenueAccount < ActiveRecord::Base

  attr_readonly :id, :opened_on

  # attr_accessible( # :id,
                   # :unique_title,
                   # :locked,
                   # :activity_period_id,
                   # :opened_on,
                   # :closed_on,
                   # :main,
                   # :amount,
                   # :amount_updated_on,
                   # :description
                 # )  ## all attributes listed here

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
