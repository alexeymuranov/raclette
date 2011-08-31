class CreateInstructors < ActiveRecord::Migration
  def up
    create_table :instructors, :primary_key => :person_id do |t|
      t.primary_key :person_id
      t.text        :presentation
      t.binary      :photo
      t.date        :employed_from
      t.date        :employed_until

      t.timestamps
    end

    # add_index :instructors, :person_id, :unique => true
    add_index :instructors, :employed_from
    add_index :instructors, :employed_until
  end

  def down
    drop_table :instructors
  end
end
