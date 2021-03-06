## encoding: UTF-8

class Address < ActiveRecord::Base

  attr_readonly :id, :country

  # Associations:
  def self.init_associations
    has_many :people, :foreign_key => :primary_address_id,
                      :dependent   => :nullify,
                      :inverse_of  => :primary_address

    has_many :weekly_events, :dependent  => :nullify,
                             :inverse_of => :address

    has_many :events, :dependent  => :nullify,
                      :inverse_of => :address
  end

  init_associations

  # Validations:
  validates :names, :country,
            :presence => true

  validates :names, :length => { :maximum => 64 }

  validates :address_type, :length    => { :maximum => 32 },
                           :inclusion => %w[Home Work Mailing],
                           :allow_nil => true

  validates :country, :length => { :maximum => 32 }

  validates :city, :length    => { :maximum => 32 },
                   :allow_nil => true

  validates :post_code, :length    => { :maximum => 16 },
                        :allow_nil => true

  validates :street_address, :length    => { :maximum => 255 },
                             :allow_nil => true
  # Scopes:
  scope :default_order, lambda {
    order("#{ table_name }.country ASC, "\
          "#{ table_name }.city ASC, "\
          "#{ table_name }.post_code ASC")
  }
end

# == Schema Information
#
# Table name: addresses
#
#  id             :integer          not null, primary key
#  names          :string(64)       not null
#  address_type   :string(32)
#  country        :string(32)       not null
#  city           :string(32)
#  post_code      :string(16)
#  street_address :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

