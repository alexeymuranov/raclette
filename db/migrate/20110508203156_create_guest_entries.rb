class CreateGuestEntries < ActiveRecord::Migration
  def self.up
    create_table :guest_entries do |t|
      t.string :first_name
      t.string :last_name
      t.integer :inviting_member_id
      t.integer :previous_entry_id
      t.integer :toward_membership_purchase_id
      t.string :email
      t.string :phone
      t.string :note

      t.timestamps
    end
  end

  def self.down
    drop_table :guest_entries
  end
end
