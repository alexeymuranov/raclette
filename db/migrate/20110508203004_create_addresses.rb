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

    add_index :addresses, :names
    add_index :addresses, :address_type
    add_index :addresses, :country
    add_index :addresses, [ :city, :country ]
    add_index :addresses, [ :post_code, :country ]
  end

  def self.down
    drop_table :addresses
  end
end
