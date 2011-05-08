class CreateWeeklyEvents < ActiveRecord::Migration
  def self.up
    create_table :weekly_events do |t|
      t.string  :event_type
      t.string  :title
      t.boolean :lesson
      t.integer :week_day
      t.string  :start_time
      t.integer :duration_minutes
      t.string  :end_time
      t.date    :start_on
      t.date    :end_on
      t.string  :location
      t.integer :address_id
      t.integer :lesson_supervision_id
      t.integer :entry_fee_tickets
      t.boolean :over
      t.string  :description

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
