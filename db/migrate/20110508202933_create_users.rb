class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string   :username
      t.string   :full_name
      t.boolean  :a_person
      t.integer  :person_id
      t.string   :email
      t.boolean  :admin
      t.boolean  :manager
      t.boolean  :secretary
      t.string   :password_or_password_hash
      t.string   :password_salt
      t.datetime :last_signed_in_at
      t.text     :comments

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
