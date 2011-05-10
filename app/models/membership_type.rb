class MembershipType < ActiveRecord::Base

  attr_readonly :id, :active, :reduced, :unlimited, :duration_months

  # attr_accessible( # :id,
                   # :unique_title,
                   # :active,
                   # :reduced,
                   # :unlimited,
                   # :duration_months,
                   # :description
                 # )  ## all attributes listed here

  has_many :memberships, :foreign_key => :membership_type_id,
                         :dependent   => :destroy,
                         :inverse_of  => :type

  has_many :activity_periods, :through => :memberships

  has_many :ticket_books, :dependent  => :destroy,
                          :inverse_of => :membership_type
end
