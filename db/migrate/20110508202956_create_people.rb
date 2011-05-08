class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string  :last_name
      t.string  :first_name
      t.string  :name_title
      t.string  :nickname_or_other
      t.integer :birthyear
      t.string  :email
      t.string  :mobile_phone
      t.string  :home_phone
      t.string  :work_phone
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
