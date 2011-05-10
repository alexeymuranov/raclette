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

  has_many :memberships, :dependent  => :destroy,
                         :inverse_of => :activity_period

  has_many :membership_types, :through => :memberships
end
