class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string  :last_name,         :limit =>  32, :null => false
      t.string  :first_name,        :limit =>  32, :null => false
      t.string  :name_title,        :limit =>  16
      t.string  :nickname_or_other, :limit =>  32,
                    :default => '',                :null => false
      t.integer :birthyear,         :limit =>   2
      t.string  :email,             :limit => 255
      t.string  :mobile_phone,      :limit =>  32
      t.string  :home_phone,        :limit =>  32
      t.string  :work_phone,        :limit =>  32
      t.integer :primary_address_id

      t.timestamps
    end

    add_index :people, [ :last_name, :first_name, :nickname_or_other ],
                  :unique => true
    add_index :people, :first_name
    add_index :people, :name_title
    add_index :people, :nickname_or_other
    add_index :people, :email
    add_index :people, :primary_address_id
  end

  def self.down
    drop_table :people
  end
end
