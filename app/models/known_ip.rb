class KnownIP < ActiveRecord::Base  ## note the class name! (capital IP)
  set_table_name :known_ips

  attr_readonly :id, :ip

  # attr_accessible( # :id,
                   # :ip,
                   # :description
                 # )  ## all attributes listed here

  has_many :safe_user_ips, :foreign_key => :known_ip_id,
                           :class_name  => :SafeUserIP,
                           :dependent   => :destroy,
                           :inverse_of  => :known_ip

  has_many :safe_users, :through => :safe_user_ips,
                        :source  => :user
end
