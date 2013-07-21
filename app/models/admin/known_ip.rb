## encoding: UTF-8

require 'app_active_record_extensions/pseudo_columns'

class Admin::KnownIP < ActiveRecord::Base
  self.table_name = 'admin_known_ips'

  include PseudoColumns
  include AbstractHumanizedModel

  attr_readonly :id, :ip

  # Associations:
  def self.init_associations
    has_many :safe_user_ips, :foreign_key => :known_ip_id,
                             :class_name  => :SafeUserIP,
                             :dependent   => :destroy,
                             :inverse_of  => :known_ip

    has_many :safe_users, :through => :safe_user_ips,
                          :source  => :user
  end

  init_associations

  # Validations:
  validates :ip, :presence   => true,
                 :format     => /\A\d{1,3}(\.\d{1,3}){3}\z/,
                 :uniqueness => true

  # Scopes:
  scope :default_order, lambda { order("#{ table_name }.ip ASC") }
end

# == Schema Information
#
# Table name: admin_known_ips
#
#  id          :integer          not null, primary key
#  ip          :string(15)       not null
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

