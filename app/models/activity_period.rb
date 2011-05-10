class ActivityPeriod < ActiveRecord::Base

  has_many :memberships, :dependent  => :destroy,
                         :inverse_of => :activity_period

  has_many :membership_types, :through => :memberships
end
