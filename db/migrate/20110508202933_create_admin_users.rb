class CreateAdminUsers < ActiveRecord::Migration
  def up
    create_table :admin_users do |t|
      t.string   :username,                  :limit =>  32, :null => false
      t.string   :full_name,                 :limit =>  64, :null => false
      t.boolean  :a_person
      t.integer  :person_id
      t.string   :email,                     :limit => 255
      t.boolean  :account_deactivated, :default => false,   :null => false
      t.boolean  :admin,               :default => false,   :null => false
      t.boolean  :manager,             :default => false,   :null => false
      t.boolean  :secretary,           :default => false,   :null => false
      t.string   :password_or_password_hash, :limit => 255,
                                       :default => '',      :null => false
      t.string   :password_salt,             :limit => 255
      t.datetime :last_signed_in_at
      t.text     :comments

      t.timestamps
    end

    add_index :admin_users, :username,
                  :unique => true
    add_index :admin_users, :full_name
    add_index :admin_users, :a_person
    add_index :admin_users, :person_id
    add_index :admin_users, :email,
                  :unique => true
    add_index :admin_users, :admin
  end

  def down
    drop_table :admin_users
  end
end
