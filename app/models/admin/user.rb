## encoding: UTF-8

# == Schema Information
# Schema version: 20110618120707
#
# Table name: admin_users
#
#  id                        :integer         not null, primary key
#  username                  :string(32)      not null
#  full_name                 :string(64)      not null
#  a_person                  :boolean
#  person_id                 :integer
#  email                     :string(255)
#  account_deactivated       :boolean         not null
#  admin                     :boolean         not null
#  manager                   :boolean         not null
#  secretary                 :boolean         not null
#  password_or_password_hash :string(255)     default(""), not null
#  password_salt             :string(255)
#  last_signed_in_at         :datetime
#  comments                  :text
#  created_at                :datetime
#  updated_at                :datetime
#  last_signed_in_from_ip    :string(15)
#

require 'digest'
require 'assets/app_validations/email_format'

class Admin::User < ActiveRecord::Base

  attr_readonly :id, :username

  attr_accessor :password, :new_password

  attr_accessible( # :id,
                   :username,
                   :full_name,
                   :a_person,
                   # :person_id,
                   :email,
                   :account_deactivated,
                   :admin,
                   :manager,
                   :secretary,
                   # :password_or_password_hash,
                   # :password_salt,
                   # :last_signed_in_at,
                   # :last_signed_in_from_ip,
                   :comments,
                   :safe_ip_ids,                # association attribute
                   :person,                     # association attribute
                   :password,                   # virtual attribute
                   :password_confirmation,      # virtual attribute
                   :new_password,               # virtual attribute
                   :new_password_confirmation   # virtual attribute
                 )  ## all attributes listed here

  # Associations:
  has_many :safe_user_ips, :class_name => 'SafeUserIP',
                           :dependent  => :destroy,
                           :inverse_of => :user

  has_many :safe_ips, :through => :safe_user_ips,
                      :source  => :known_ip

  has_many :application_journal_records, :dependent  => :nullify,
                                         :inverse_of => :user

  # Validations:
  validates :username, :full_name,
                :presence => true

  validates :password, :confirmation => true,
                       :length       => { :maximum => 128 },
                       :format       => /\A[\x21-\x7E]*\z/,
                       :on           => :create

  validates :new_password, :confirmation => true,
                           :length       => { :maximum => 128 },
                           :format       => /\A[\x21-\x7E]*\z/,
                           :allow_blank  => true,
                           :on           => :update

  validates :username, :length    => { :maximum => 32 },
                       :format    => /\A[a-z0-9_.\-]+\z/,
                       :exclusion => %w[ admin superuser ]

  validates :full_name, :length => { :maximum => 64 }

  validates :email, :length       => { :maximum => 255 },
                    :email_format => true,
                    :allow_nil    => true

  validates :comments, :length    => { :maximum => 4*1024 },
                       :allow_nil => true

  validates :username, :uniqueness => { :case_sensitive => false }

  # Callbacks:
  before_create :hash_password_with_salt

  before_update :hash_new_password_with_salt_unless_nil

  # Scopes:
  scope :default_order, order('username ASC')
  scope :admins, where(:admin => true)
  scope :managers, where(:manager => true)
  scope :secretaries, where(:secretary => true)
  scope :humans, where(:a_person => true)

  # Public methods:
  def has_password?(submitted_password)
    (password_or_password_hash == submitted_password) ||
        (password_or_password_hash == hash_with_salt(submitted_password))
  end

  def self.authenticate(username, submitted_password)
    user = find_by_username(username)
    user && user.has_password?(submitted_password) ? user : nil
  end

  def formatted_email
    "#{full_name} <#{email}>"
  end

  # Private methods:
  private

    def hash_password_with_salt
      self.password_salt = make_salt # if new_record?
      self.password_or_password_hash = hash_with_salt(password)
    end

    def hash_new_password_with_salt_unless_nil
      unless new_password.nil?
        self.password_salt = make_salt # if new_record?
        self.password_or_password_hash = hash_with_salt(new_password)
      end
    end

    def hash_with_salt(string)
      secure_hash("#{password_salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end

end
