## encoding: UTF-8

require 'app_active_record_extensions/sorting'

class Admin::KnownIP < ActiveRecord::Base
  self.table_name = 'admin_known_ips'

  include Sorting
  self.default_sorting_column = :ip

  include AbstractSmarterModel
  include AbstractHumanizedModel

  attr_readonly :id, :ip

  # Associations:
  has_many :safe_user_ips, :foreign_key => :known_ip_id,
                           :class_name  => :SafeUserIP,
                           :dependent   => :destroy,
                           :inverse_of  => :known_ip

  has_many :safe_users, :through => :safe_user_ips,
                        :source  => :user

  # Validations:
  validates :ip, :presence   => true,
                 :format     => /\A\d{1,3}(\.\d{1,3}){3}\z/,
                 :uniqueness => true

  # Scopes:
  scope :default_order, order('ip ASC')

end
