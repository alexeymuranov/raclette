class CreateWeeklyEvents < ActiveRecord::Migration
  def self.up
    create_table :weekly_events do |t|
      t.string  :event_type,        :limit =>  32, :null => false
      t.string  :title,             :limit =>  64, :null => false
      t.boolean :lesson,                           :null => false
      t.integer :week_day,          :limit =>   1, :null => false
      t.string  :start_time,        :limit =>   8
      t.integer :duration_minutes,  :limit =>   2,
                         :default => 60
      t.string  :end_time,          :limit =>   8
      t.date    :start_on,                         :null => false
      t.date    :end_on
      t.string  :location,          :limit =>  64
      t.integer :address_id
      t.integer :lesson_supervision_id
      t.integer :entry_fee_tickets, :limit =>   1
      t.boolean :over,   :default => false,        :null => false
      t.string  :description,       :limit => 255

      t.timestamps
    end

    add_index :weekly_events, [ :event_type, :title ]
    add_index :weekly_events, [ :title, :start_on ],
                  :unique => true
    add_index :weekly_events, [ :title, :end_on ],
                  :unique => true
    add_index :weekly_events, :lesson
    add_index :weekly_events, :start_on
    add_index :weekly_events, :end_on
    add_index :weekly_events, :week_day
    add_index :weekly_events, :address_id
    add_index :weekly_events, :lesson_supervision_id
    add_index :weekly_events, [ :over, :end_on ]
  end

  def self.down
    drop_table :weekly_events
  end
end
