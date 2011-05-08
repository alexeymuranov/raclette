class CreateWeeklyEventSuspensions < ActiveRecord::Migration
  def self.up
    create_table :weekly_event_suspensions do |t|
      t.integer :weekly_event_id
      t.date    :suspend_from
      t.date    :suspend_until
      t.string  :explanation

      t.timestamps
    end

    add_index :weekly_event_suspensions, [ :weekly_event_id, :suspend_from ],
                  :name   => 'index_weekly_event_suspensions_on'\
                             '_w_e_id_and_suspend_from',
                  :unique => true
    add_index :weekly_event_suspensions, [ :weekly_event_id, :suspend_until ],
                  :name   => 'index_weekly_event_suspensions_on'\
                             '_w_e_id_and_suspend_until',
                  :unique => true
    add_index :weekly_event_suspensions, :suspend_from
    add_index :weekly_event_suspensions, :suspend_until
  end

  def self.down
    drop_table :weekly_event_suspensions
  end
end
