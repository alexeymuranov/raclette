class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :names
      t.string :address_type
      t.string :country
      t.string :city
      t.string :post_code
      t.string :street_address

      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
