class CreateInstructors < ActiveRecord::Migration
  def self.up
    create_table :instructors, :primary_key => :person_id do |t|
      t.primary_key :person_id
      t.text        :presentation, :limit => 32*1024
      t.binary      :photo,        :limit => 2.megabytes
      t.date        :employed_from
      t.date        :employed_until

      t.timestamps
    end

    # add_index :instructors, :person_id, :unique => true
    add_index :instructors, :employed_from
    add_index :instructors, :employed_until
  end

  def self.down
    drop_table :instructors
  end
end
