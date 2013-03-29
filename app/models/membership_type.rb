## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'
require 'app_active_record_extensions/pseudo_columns'

class MembershipType < ActiveRecord::Base
  include Filtering
  include Sorting

  include PseudoColumns
  include AbstractHumanizedModel

  attr_readonly :id, :active, :reduced, :unlimited, :duration_months

  # Associations:
  def self.init_associations
    has_many :memberships, :foreign_key => :membership_type_id,
                           :dependent   => :destroy,
                           :inverse_of  => :membership_type

    has_many :activity_periods, :through => :memberships
  end

  init_associations

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
  scope :default_order, order("#{ table_name }.duration_months DESC, "\
                              "#{ table_name }.unique_title ASC")
end

# == Schema Information
#
# Table name: membership_types
#
#  id              :integer          not null, primary key
#  unique_title    :string(32)       not null
#  active          :boolean          default(FALSE), not null
#  reduced         :boolean          default(FALSE), not null
#  unlimited       :boolean          default(FALSE), not null
#  duration_months :integer          default(12), not null
#  description     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

