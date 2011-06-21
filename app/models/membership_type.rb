## encoding: UTF-8

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

  # Associations:
  has_many :memberships, :foreign_key => :membership_type_id,
                         :dependent   => :destroy,
                         :inverse_of  => :type

  has_many :activity_periods, :through => :memberships

  has_many :ticket_books, :dependent  => :destroy,
                          :inverse_of => :membership_type

  # Validations:
  validates :unique_title, :duration_months,
                :presence => true

  validates :unique_title, :length => 1..32

  validates :duration_months, :inclusion  => 1..12

  validates :description, :length    => { :maximum => 255 },
                          :allow_nil => true

  validates :unique_title, :uniqueness => { :case_sensitive => false }

  validates :duration_months,
                :uniqueness => { :scope => [ :active, :reduced, :unlimited ] }
end
