## encoding: UTF-8

class ActivityPeriod < ActiveRecord::Base

  attr_readonly :id, :start_date, :duration_months, :end_date

  # Associations:
  has_many :memberships, :dependent  => :destroy,
                         :inverse_of => :activity_period

  has_many :membership_types, :through => :memberships

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
  scope :default_order, order('end_date DESC, start_date DESC')
end
# == Schema Information
#
# Table name: activity_periods
#
#  id              :integer         not null, primary key
#  unique_title    :string(64)      not null
#  start_date      :date            not null
#  duration_months :integer(1)      default(12), not null
#  end_date        :date            not null
#  over            :boolean         default(FALSE), not null
#  description     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

