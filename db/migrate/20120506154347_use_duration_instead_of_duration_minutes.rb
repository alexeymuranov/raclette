class UseDurationInsteadOfDurationMinutes < ActiveRecord::Migration
  def up
    add_column('events', :duration, :time)
    add_column('weekly_events', :duration, :time)
    remove_column('events', :duration_minutes)
    remove_column('weekly_events', :duration_minutes)
   end

  def down
    add_column('events', :duration_minutes, :integer, :limit => 2)
    add_column('weekly_events', :duration_minutes, :integer, :limit => 2)
    remove_column('events', :duration)
    remove_column('weekly_events', :duration)
   end
end
