class SafeUserIP < ActiveRecord::Base  ## note the class name! (capital IP)
  set_table_name :safe_user_ips
end