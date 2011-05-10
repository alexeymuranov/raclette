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

  has_many :users, :dependent  => :nullify,
                   :inverse_of => :person

  has_one :statement, :class_name => :PersonalStatement,
                      :dependent  => :destroy,
                      :inverse_of => :person

  has_one :instructor, :dependent  => :destroy,
                       :inverse_of => :person

  has_many :committee_memberships, :dependent  => :destroy,
                                   :inverse_of => :person

  has_one :member, :dependent  => :destroy,
                   :inverse_of => :person

  has_many :payments, :foreign_key => :payer_person_id
                      :dependent   => :nullify,
                      :inverse_of  => :payer

  has_many :event_entries, :dependent  => :destroy,
                           :inverse_of => :person

  has_many :event_cashiers, :dependent  => :nullify,
                            :inverse_of => :person

  belongs_to :primary_address, :class_name => :Address,
                               :inverse_of => :people
end
