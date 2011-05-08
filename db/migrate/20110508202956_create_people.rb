class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :last_name
      t.string :first_name
      t.string :name_title
      t.string :nickname_or_other
      t.integer :birthyear
      t.string :email
      t.string :mobile_phone
      t.string :home_phone
      t.string :work_phone
      t.integer :primary_address_id

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
