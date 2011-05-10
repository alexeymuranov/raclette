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

  # Associations:
  has_many :safe_user_ips, :class_name => :SafeUserIP,
                           :dependent  => :destroy,
                           :inverse_of => :user

  has_many :safe_ips, :through => :safe_user_ips,
                      :source  => :known_ip

  has_many :application_journal_records, :dependent  => :nullify,
                                         :inverse_of => :user

  # Validations:
  validates :username, :full_name,
                :presence => true

  validates :username, :length    => { :maximum => 32 },
                       :format    => /\A[a-z0-9_.\-]+\z/,
                       :exclusion => %w[ admin superuser ]

  validates :full_name, :length => { :maximum => 64 }

  validates :email, :length    => { :maximum => 255 },
                    :format    => ACCEPTABLE_EMAIL_ADDRESS_FORMAT,
                    :allow_nil => true

  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :maximum => 64 },
                       :format       => /\A[\x21-\x7E]*\z/

  validates :comments, :length    => { :maximum => 4*1024 },
                       :allow_nil => true

  validates :username, :email,
                :uniqueness => { :case_sensitive => false }
end
