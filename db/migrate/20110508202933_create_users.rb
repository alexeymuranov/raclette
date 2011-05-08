class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :full_name
      t.boolean :a_person
      t.integer :person_id
      t.string :email
      t.boolean :admin
      t.boolean :manager
      t.boolean :secretary
      t.string :password_or_encrypted_password
      t.string :salt
      t.datetime :last_connected_at
      t.text :comments

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
