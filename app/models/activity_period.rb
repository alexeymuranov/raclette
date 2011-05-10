class ActivityPeriod < ActiveRecord::Base

  attr_readonly :id, :start_date, :duration_months, :end_date

  # attr_accessible( # :id,
                   # :unique_title,
                   # :start_date,
                   # :duration_months,
                   # :end_date,
                   # :over,
                   # :description
                 # )  ## all attributes listed here

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
end
