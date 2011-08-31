class CreateGuestEntries < ActiveRecord::Migration
  def up
    create_table :guest_entries do |t|
      t.string  :first_name, :limit =>  32, :null => false
      t.string  :last_name,  :limit =>  32
      t.integer :inviting_member_id
      t.integer :previous_entry_id
      t.integer :toward_membership_purchase_id
      t.string  :email,      :limit => 255
      t.string  :phone,      :limit =>  32
      t.string  :note,       :limit => 255

      t.timestamps
    end

    add_index :guest_entries, :first_name
    add_index :guest_entries, [ :last_name, :first_name ]
    add_index :guest_entries, :inviting_member_id
    add_index :guest_entries, :previous_entry_id,
                  :unique => true
    add_index :guest_entries, :toward_membership_purchase_id
  end

  def down
    drop_table :guest_entries
  end
end
