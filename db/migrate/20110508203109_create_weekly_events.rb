class CreateWeeklyEvents < ActiveRecord::Migration
  def self.up
    create_table :weekly_events do |t|
      t.string :event_type
      t.string :title
      t.boolean :lesson
      t.integer :week_day
      t.string :start_time
      t.integer :duration_minutes
      t.string :end_time
      t.date :start_on
      t.date :end_on
      t.string :location
      t.integer :address_id
      t.integer :lesson_supervision_id
      t.integer :entry_fee_tickets
      t.boolean :over
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :weekly_events
  end
end
