class SafeUserIP < ActiveRecord::Base  ## note the class name! (capital IP)
  set_table_name :safe_user_ips

  belongs_to :user, :inverse_of => :safe_user_ips

  belongs_to :known_ip, :class_name => :KnownIP,
                        :inverse_of => :safe_user_ips
end