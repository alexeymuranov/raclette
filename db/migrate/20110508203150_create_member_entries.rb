class CreateMemberEntries < ActiveRecord::Migration
  def up
    create_table :member_entries do |t|
      t.integer :member_id,                                :null => false
      t.integer :guests_invited,            :default => 0
      t.integer :tickets_used, :limit => 1, :default => 0, :null => false

      t.timestamps
    end

    add_index :member_entries, [ :member_id, :guests_invited ]
  end

  def down
    drop_table :member_entries
  end
end
