class CreateEventEntries < ActiveRecord::Migration
  def self.up
    create_table :event_entries do |t|
      t.string :participant_entry_type
      t.integer :participant_entry_id
      t.string :event_title
      t.date :date
      t.integer :event_id
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :event_entries
  end
end
