class User < ActiveRecord::Base

  attr_readonly :id, :username

  # attr_accessible( # :id,
                   # :username,
                   # :full_name,
                   # :a_person,
                   # :person_id,
                   # :email,
                   # :admin,
                   # :manager,
                   # :secretary,
                   # :password_or_password_hash,
                   # :password_salt,
                   # :last_signed_in_at,
                   # :comments
                 # )  ## all attributes listed here

  has_many :safe_user_ips, :class_name => :SafeUserIP,
                           :dependent  => :destroy,
                           :inverse_of => :user

  has_many :safe_ips, :through => :safe_user_ips,
                      :source  => :known_ip

  has_many :application_journal_records, :dependent  => :nullify,
                                         :inverse_of => :user
end
