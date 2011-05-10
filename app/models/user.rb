class User < ActiveRecord::Base

  has_many :safe_user_ips, :class_name => :SafeUserIP,
                           :dependent  => :destroy,
                           :inverse_of => :user

  has_many :safe_ips, :through => :safe_user_ips,
                      :source  => :known_ip

  has_many :application_journal_records, :dependent  => :nullify,
                                         :inverse_of => :user
end
