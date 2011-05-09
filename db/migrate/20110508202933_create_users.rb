class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :username,                  :limit =>  32, :null => false
      t.string   :full_name,                 :limit =>  64, :null => false
      t.boolean  :a_person
      t.integer  :person_id
      t.string   :email,                     :limit => 255
      t.boolean  :admin,     :default => false,             :null => false
      t.boolean  :manager,   :default => false,             :null => false
      t.boolean  :secretary, :default => false,             :null => false
      t.string   :password_or_password_hash, :limit => 255,
                             :default => '',                :null => false
      t.string   :password_salt,             :limit => 255
      t.datetime :last_signed_in_at
      t.text     :comments,                  :limit => 4*1024

      t.timestamps
    end

    add_index :users, :username,
                  :unique => true
    add_index :users, :full_name
    add_index :users, :a_person
    add_index :users, :person_id
    add_index :users, :email,
                  :unique => true
    add_index :users, :admin
  end

  def self.down
    drop_table :users
  end
end
