class RemoveDateAndEventTitleFromEventEntries < ActiveRecord::Migration
  def up
    remove_index :event_entries,
                 'participant_entry_type_and_p_e_id'

    change_table :event_entries do |t|
      t.change :event_id, :integer, :null => false
      t.remove :event_title
      t.remove :date
    end

    add_index :event_entries,
              [:participant_entry_type, :participant_entry_id],
              :name   =>
                'index_event_entries_on_participant_entry_type_and_p_e_id',
              :unique => true
  end

  def down
    remove_index :event_entries,
                 'participant_entry_type_and_p_e_id'

    change_table :event_entries do |t|
      t.change :event_id, :integer, :null => true
      t.string :event_title, :limit => 64, :null => false
      t.date   :date,                      :null => false
      t.index  :date
    end

    add_index :event_entries,
              [:participant_entry_type, :participant_entry_id],
              :name   =>
                'index_event_entries_on_participant_entry_type_and_p_e_id',
              :unique => true
  end
end
