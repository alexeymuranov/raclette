## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'

class MembershipType < ActiveRecord::Base
  include Filtering
  include Sorting

  include AbstractSmarterModel

  attr_readonly :id, :active, :reduced, :unlimited, :duration_months

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

  # Scopes:
  scope :default_order, order('duration_months DESC, unique_title ASC')
end
# == Schema Information
#
# Table name: membership_types
#
#  id              :integer         not null, primary key
#  unique_title    :string(32)      not null
#  active          :boolean         default(FALSE), not null
#  reduced         :boolean         default(FALSE), not null
#  unlimited       :boolean         default(FALSE), not null
#  duration_months :integer(1)      default(12), not null
#  description     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

