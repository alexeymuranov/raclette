class Address < ActiveRecord::Base

  attr_readonly :id, :country

  # attr_accessible( # :id,
                   # :names,
                   # :address_type,
                   # :country,
                   # :city,
                   # :post_code,
                   # :street_address
                 # )  ## all attributes listed here

  # Associations:
  has_many :people, :foreign_key => :primary_address_id,
                    :dependent   => :nullify,
                    :inverse_of  => :primary_address

  has_many :weekly_events, :dependent  => :nullify,
                           :inverse_of => :address

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :address

  # Validations:
  validates :names, :country,
                :presence => true

  validates :names, :length => { :maximum => 64 }

  validates :address_type, :length    => { :maximum => 32 },
                           :inclusion => %w[ Home Work Mailing ],
                           :allow_nil => true

  validates :country, :length => { :maximum => 32 }

  validates :city, :length    => { :maximum => 32 },
                   :allow_nil => true

  validates :post_code, :length    => { :maximum => 16 },
                        :allow_nil => true

  validates :street_address, :length    => { :maximum => 255 },
                             :allow_nil => true
end
