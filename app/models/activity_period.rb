## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'
require 'app_active_record_extensions/pseudo_columns'

class ActivityPeriod < ActiveRecord::Base
  include Filtering
  include Sorting

  include PseudoColumns
  include AbstractHumanizedModel

  attr_readonly :id, :start_date, :duration_months, :end_date

  # Associations:
  has_many :memberships, :dependent  => :destroy,
                         :inverse_of => :activity_period

  has_many :membership_types, :through => :memberships,
                              :source  => :membership_type

  has_many :revenue_accounts, :dependent  => :nullify,
                              :inverse_of => :activity_period

  # Validations:
  validates :unique_title, :start_date, :duration_months, :end_date,
            :presence => true

  validates :unique_title, :length => 1..64

  validates :duration_months, :inclusion => 1..12

  validates :description, :length    => { :maximum => 255 },
                          :allow_nil => true

  validates :unique_title, :uniqueness => { :case_sensitive => false }

  validates :duration_months, :uniqueness => { :scope => :start_date }

  # Scopes:
  scope :order_by_end_date, order("#{ table_name }.end_date ASC, "\
                                  "#{ table_name }.start_date ASC")
  scope :reverse_order_by_end_date, order_by_end_date.reverse_order
  scope :default_order, reverse_order_by_end_date
  scope :current, lambda {
    where("#{ table_name }.start_date <= :today AND "\
          "#{ table_name }.end_date >= :today",
          :today => Date.today)
  }
  scope :not_over, lambda {
    where("#{ table_name }.end_date >= ?", Date.today)
  }


  # Public instance methods
  # Non-SQL virtual attributes
  #
  def virtually_over?
    end_date < Date.today
  end
end

# == Schema Information
#
# Table name: activity_periods
#
#  id              :integer          not null, primary key
#  unique_title    :string(64)       not null
#  start_date      :date             not null
#  duration_months :integer          default(12), not null
#  end_date        :date             not null
#  over            :boolean          default(FALSE), not null
#  description     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

