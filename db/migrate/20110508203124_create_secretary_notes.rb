class CreateSecretaryNotes < ActiveRecord::Migration
  def self.up
    create_table :secretary_notes do |t|
      t.string :note_type
      t.string :message
      t.string :something_type
      t.integer :something_id
      t.datetime :message_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :secretary_notes
  end
end
