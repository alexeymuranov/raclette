class CreateEvents < ActiveRecord::Migration
  def up
    create_table :events do |t|
      t.string  :event_type,           :limit =>  32, :null => false
      t.string  :title,                :limit =>  64
      t.boolean :locked,                              :default => false,
                                                      :null => false
      t.boolean :lesson,                              :null => false
      t.date    :date
      t.string  :start_time,           :limit =>   8
      t.integer :duration_minutes,     :limit =>   2
      t.string  :end_time,             :limit =>   8
      t.string  :location,             :limit =>  64
      t.integer :address_id
      t.boolean :weekly,                              :default => false,
                                                      :null => false
      t.integer :weekly_event_id
      t.string  :supervisors,          :limit => 255
      t.integer :lesson_supervision_id
      t.integer :entry_fee_tickets,    :limit =>   1
      t.decimal :member_entry_fee,     :scale => 1, :precision => 3
      t.decimal :couple_entry_fee,     :scale => 1, :precision => 3
      t.decimal :common_entry_fee,     :scale => 1, :precision => 3
      t.boolean :over,                                :default => false,
                                                      :null => false
      t.integer :reservations_count,   :limit =>   2, :default => 0
      t.integer :entries_count,        :limit =>   2, :default => 0
      t.integer :member_entries_count, :limit =>   2, :default => 0
      t.integer :tickets_collected,    :limit =>   2, :default => 0
      t.decimal :entry_fees_collected, :scale => 1, :precision => 6,
                                                      :default => 0
      t.string  :description,          :limit => 255

      t.timestamps
    end

    add_index :events, [ :event_type, :title ]
    add_index :events, [ :title, :date ]
    add_index :events, [ :locked, :date ]
    add_index :events, :lesson
    add_index :events, :date
    add_index :events, :address_id
    add_index :events, :weekly
    add_index :events, :weekly_event_id
    add_index :events, :lesson_supervision_id
    add_index :events, [ :over, :date ]
  end

  def down
    drop_table :events
  end
end
