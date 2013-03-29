## encoding: UTF-8

class Admin::SafeUserIP < ActiveRecord::Base
  self.table_name = 'admin_safe_user_ips'

  attr_readonly :id, :known_ip_id, :user_id

  # Associations:
  def self.init_associations
    belongs_to :user, :inverse_of => :safe_user_ips

    belongs_to :known_ip, :class_name => :KnownIP,
                          :inverse_of => :safe_user_ips
  end

  init_associations

  # Validations:
  validates :known_ip_id, :user_id,
            :presence => true

  validates :known_ip_id, :uniqueness => { :scope => :user_id }
end

# == Schema Information
#
# Table name: admin_safe_user_ips
#
#  id           :integer          not null, primary key
#  known_ip_id  :integer          not null
#  user_id      :integer          not null
#  last_used_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

