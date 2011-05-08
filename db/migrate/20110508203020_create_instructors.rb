class CreateInstructors < ActiveRecord::Migration
  def self.up
    create_table :instructors, :primary_key => :person_id do |t|
      t.primary_key :person_id
      t.text :presentation
      t.binary :photo
      t.date :employed_from
      t.date :employed_until

      t.timestamps
    end
  end

  def self.down
    drop_table :instructors
  end
end
