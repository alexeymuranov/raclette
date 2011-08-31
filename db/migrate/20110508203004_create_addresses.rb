class CreateAddresses < ActiveRecord::Migration
  def up
    create_table :addresses do |t|
      t.string :names,          :limit =>  64, :null => false
      t.string :address_type,   :limit =>  32
      t.string :country,        :limit =>  32, :null => false
      t.string :city,           :limit =>  32
      t.string :post_code,      :limit =>  16
      t.string :street_address, :limit => 255

      t.timestamps
    end

    add_index :addresses, :names
    add_index :addresses, :address_type
    add_index :addresses, :country
    add_index :addresses, [ :city, :country ]
    add_index :addresses, [ :post_code, :country ]
  end

  def down
    drop_table :addresses
  end
end
