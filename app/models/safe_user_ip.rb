class SafeUserIP < ActiveRecord::Base  ## note the class name! (capital IP)
  set_table_name :safe_user_ips

  attr_readonly :id, :known_ip_id, :user_id

  # attr_accessible( # :id,
                   # :known_ip_id,
                   # :user_id,
                   # :last_signed_in_at
                 # )  ## all attributes listed here

  belongs_to :user, :inverse_of => :safe_user_ips

  belongs_to :known_ip, :class_name => :KnownIP,
                        :inverse_of => :safe_user_ips
end