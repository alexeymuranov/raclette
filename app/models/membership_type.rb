class MembershipType < ActiveRecord::Base

  has_many :memberships, :foreign_key => :membership_type_id,
                         :dependent   => :destroy,
                         :inverse_of  => :type

  has_many :activity_periods, :through => :memberships

  has_many :ticket_books, :dependent  => :destroy,
                          :inverse_of => :membership_type
end
