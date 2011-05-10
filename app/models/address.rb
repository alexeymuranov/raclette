class Address < ActiveRecord::Base

  has_many :people, :foreign_key => :primary_address_id,
                    :dependent   => :nullify,
                    :inverse_of  => :primary_address

  has_many :weekly_events, :dependent  => :nullify,
                           :inverse_of => :address

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :address
end
