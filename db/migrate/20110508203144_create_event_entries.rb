class CreateEventEntries < ActiveRecord::Migration
  def self.up
    create_table :event_entries do |t|
      t.string  :participant_entry_type, :limit => 32, :null => false
      t.integer :participant_entry_id
      t.string  :event_title,            :limit => 64, :null => false
      t.date    :date,                                 :null => false
      t.integer :event_id
      t.integer :person_id

      t.timestamps
    end

    add_index :event_entries, :participant_entry_type
    add_index :event_entries, [ :participant_entry_type,
                                :participant_entry_id ],
                  :name   => 'index_event_entries_on'\
                             '_participant_entry_type_and_p_e_id',
                  :unique => true
    add_index :event_entries, :date
    add_index :event_entries, [ :event_id, :person_id ],
                  :unique => true
    add_index :event_entries, :person_id
  end

  def self.down
    drop_table :event_entries
  end
end
