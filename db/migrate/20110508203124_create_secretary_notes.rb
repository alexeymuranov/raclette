class CreateSecretaryNotes < ActiveRecord::Migration
  def up
    create_table :secretary_notes do |t|
      t.string   :note_type,      :limit => 32, :null => false
      t.string   :something_type, :limit => 32, :null => false
      t.integer  :something_id
      t.date     :created_on,                   :null => false
      t.text     :message
      t.datetime :message_updated_at,           :null => false

      t.timestamps
    end

    add_index :secretary_notes, [ :note_type, :message_updated_at ]
    add_index :secretary_notes, [ :something_type, :something_id ]
    add_index :secretary_notes, [ :note_type, :something_type,
                                  :something_id ],
                  :name   => 'index_secretary_notes_on'\
                             '_note_type_and_s_type_and_s_id',
                  :unique => true
    add_index :secretary_notes, :created_on
    add_index :secretary_notes, :message_updated_at
  end

  def down
    drop_table :secretary_notes
  end
end
