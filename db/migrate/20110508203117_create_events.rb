class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :event_type
      t.string :title
      t.boolean :locked
      t.boolean :lesson
      t.date :date
      t.string :start_time
      t.integer :duration_minutes
      t.string :end_time
      t.string :location
      t.integer :address_id
      t.boolean :weekly
      t.integer :weekly_event_id
      t.string :supervisors
      t.integer :lesson_supervision_id
      t.integer :entry_fee_tickets
      t.decimal :member_entry_fee
      t.decimal :couple_entry_fee
      t.decimal :common_entry_fee
      t.boolean :over
      t.integer :reservations_count
      t.integer :entries_count
      t.integer :member_entries_count
      t.integer :tickets_collected
      t.decimal :entry_fees_collected
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
