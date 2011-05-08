class CreateSecretaryNotes < ActiveRecord::Migration
  def self.up
    create_table :secretary_notes do |t|
      t.string   :note_type
      t.string   :message
      t.string   :something_type
      t.integer  :something_id
      t.datetime :message_updated_at

      t.timestamps
    end

    add_index :secretary_notes, [ :note_type, :message_updated_at ]
    add_index :secretary_notes, [ :something_type, :something_id ]
    add_index :secretary_notes, [ :note_type, :something_type,
                                  :something_id ],
                  :name   => 'index_secretary_notes_on'\
                             '_note_type_and_s_type_and_s_id',
                  :unique => true
    add_index :secretary_notes, :message_updated_at
  end

  def self.down
    drop_table :secretary_notes
  end
end
