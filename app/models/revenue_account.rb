## encoding: UTF-8

class RevenueAccount < ActiveRecord::Base
  # TODO: decide if 'main' boolean field is necessary, and how to use it.
  # It was intended to be used to automaticaly choose a single active
  # account.

  attr_readonly :id, :opened_on

  # Associations:
  def self.init_associations
    belongs_to :activity_period, :inverse_of => :revenue_accounts

    has_many :payments, :dependent  => :nullify,
                        :inverse_of => :revenue_account
  end

  init_associations

  # Validations:
  validates :unique_title, :opened_on, :amount, :amount_updated_on,
            :presence => true

  validates :unique_title, :length => 1..64

  validates :description, :length    => { :maximum => 255 },
                          :allow_nil => true

  validates :unique_title, :uniqueness => { :case_sensitive => false }

  # Scopes:
  scope :unlocked, lambda { where(:locked => false) }
  scope :current, lambda {
    where("#{ table_name }.opened_on <= :today AND "\
          "#{ table_name }.closed_on => :today",
          :today => Date.today)
  }
  scope :default_order, lambda {
    order("#{ table_name }.closed_on DESC, "\
          "#{ table_name }.opened_on DESC")
  }

  # Public class methods
  def self.the_active!
    # TODO: decide if to use 'main' boolean field
    count = (active_ones = unlocked.current).count
    if count == 1
      return active_ones.first
    elsif count == 0
      return nil
    else
      raise "Multiple current revenue accounts are unlocked, do not know which one to choose. "\
            "Please ensure that at most one active account is unlocked at any time."
    end
  end

  # Public instance methods
  def register(payment)
    fail # TODO
  end
end

# == Schema Information
#
# Table name: revenue_accounts
#
#  id                 :integer          not null, primary key
#  unique_title       :string(64)       not null
#  locked             :boolean          default(FALSE), not null
#  activity_period_id :integer
#  opened_on          :date
#  closed_on          :date
#  main               :boolean          default(FALSE), not null
#  amount             :decimal(7, 2)    default(0.0), not null
#  amount_updated_on  :date
#  description        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

