class CreateMemberEntries < ActiveRecord::Migration
  def self.up
    create_table :member_entries do |t|
      t.integer :member_id
      t.integer :guests_invited
      t.integer :tickets_used

      t.timestamps
    end

    add_index :member_entries, [ :member_id, :guests_invited ]
  end

  def self.down
    drop_table :member_entries
  end
end
