class CreateGuestEntries < ActiveRecord::Migration
  def self.up
    create_table :guest_entries do |t|
      t.string  :first_name
      t.string  :last_name
      t.integer :inviting_member_id
      t.integer :previous_entry_id
      t.integer :toward_membership_purchase_id
      t.string  :email
      t.string  :phone
      t.string  :note

      t.timestamps
    end

    add_index :guest_entries, :first_name
    add_index :guest_entries, [ :last_name, :first_name ]
    add_index :guest_entries, :inviting_member_id
    add_index :guest_entries, :previous_entry_id,
                  :unique => true
    add_index :guest_entries, :toward_membership_purchase_id
  end

  def self.down
    drop_table :guest_entries
  end
end
