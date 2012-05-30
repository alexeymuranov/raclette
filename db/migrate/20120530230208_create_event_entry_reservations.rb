class CreateEventEntryReservations < ActiveRecord::Migration
  def change
    create_table :event_entry_reservations do |t|
      t.integer :event_id,                     :null => false
      t.integer :people_number, :limit =>  1,
                            :default => 1,     :null => false
      t.string  :names,         :limit =>  64, :null => false
      t.integer :member_id
      t.integer :previous_guest_entry_id
      t.string  :contact_email, :limit => 255
      t.string  :contact_phone, :limit =>  32
      t.decimal :amount_payed, :scale => 1, :precision => 3,
                            :default => 0,     :null => false
      t.boolean :cancelled, :default => false, :null => false
      t.string  :note,          :limit => 255

      t.timestamps
    end
    
    add_index :event_entry_reservations, [ :event_id, :names ],
                  :unique => true
    add_index :event_entry_reservations, [ :event_id, :member_id ],
                  :unique => true
    add_index :event_entry_reservations, [ :event_id,
                                           :previous_guest_entry_id ],
                  :name   => 'index_event_entry_reservations_on'\
                             '_event_id_and_prev_g_entry_id',
                  :unique => true
    add_index :event_entry_reservations, :people_number
    add_index :event_entry_reservations, :names
    add_index :event_entry_reservations, :member_id
    add_index :event_entry_reservations, :previous_guest_entry_id
    add_index :event_entry_reservations, :cancelled
  end
end
