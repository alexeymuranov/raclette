## encoding: UTF-8

class Admin::SafeUserIP < ActiveRecord::Base
  self.table_name = 'admin_safe_user_ips'

  attr_readonly :id, :known_ip_id, :user_id

  # Associations:
  belongs_to :user, :inverse_of => :safe_user_ips

  belongs_to :known_ip, :class_name => :KnownIP,
                        :inverse_of => :safe_user_ips

  # Validations:
  validates :known_ip_id, :user_id,
                :presence => true

  validates :known_ip_id, :uniqueness => { :scope => :user_id }

end
