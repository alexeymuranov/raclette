class CreateWeeklyEventSuspensions < ActiveRecord::Migration
  def self.up
    create_table :weekly_event_suspensions do |t|
      t.integer :weekly_event_id
      t.date :suspend_from
      t.date :suspend_until
      t.string :explanation

      t.timestamps
    end
  end

  def self.down
    drop_table :weekly_event_suspensions
  end
end
