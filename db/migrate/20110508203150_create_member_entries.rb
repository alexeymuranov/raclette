class CreateMemberEntries < ActiveRecord::Migration
  def self.up
    create_table :member_entries do |t|
      t.integer :member_id
      t.integer :guests_invited
      t.integer :tickets_used

      t.timestamps
    end
  end

  def self.down
    drop_table :member_entries
  end
end
