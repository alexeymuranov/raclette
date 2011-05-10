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

  has_many :people, :foreign_key => :primary_address_id,
                    :dependent   => :nullify,
                    :inverse_of  => :primary_address

  has_many :weekly_events, :dependent  => :nullify,
                           :inverse_of => :address

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :address
end
