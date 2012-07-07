class Person < ActiveRecord::Base

  attr_readonly :id, :last_name

  # attr_accessible( # :id,
                   # :last_name,
                   # :first_name,
                   # :name_title,
                   # :nickname_or_other,
                   # :birthyear
                   # :email,
                   # :mobile_phone,
                   # :home_phone,
                   # :work_phone,
                   # :primary_address_id,
                 # )  ## all attributes listed here

  # Associations:
  has_many :users, :dependent  => :nullify,
                   :inverse_of => :person

  has_one :statement, :class_name => 'PersonalStatement',
                      :dependent  => :destroy,
                      :inverse_of => :person

  has_one :instructor, :dependent  => :destroy,
                       :inverse_of => :person

  has_many :committee_memberships, :dependent  => :destroy,
                                   :inverse_of => :person

  has_one :member, :dependent  => :destroy,
                   :inverse_of => :person

  has_many :payments, :foreign_key => :payer_person_id,
                      :dependent   => :nullify,
                      :inverse_of  => :payer

  has_many :event_entries, :dependent  => :destroy,
                           :inverse_of => :person

  has_many :event_cashiers, :dependent  => :nullify,
                            :inverse_of => :person

  belongs_to :primary_address, :class_name => 'Address',
                               :inverse_of => :people

  # Validations:
  validates :last_name, :first_name,
                :presence => true

  validates :last_name, :first_name, :nickname_or_other,
                :length   => { :maximum => 32 }

  validates :name_title, :length    => { :maximum => 16 },
                         :allow_nil => true

  validates :birthyear, :inclusion => 1900..2099,
                        :allow_nil => true

  validates :email, :length       => { :maximum => 255 },
                    :email_format => true,
                    :allow_nil    => true

  validates :mobile_phone, :home_phone, :work_phone,
                :length    => { :maximum => 32 },
                :allow_nil => true

  validates :nickname_or_other,
                :uniqueness => { :scope => [ :last_name, :first_name ] }
end
