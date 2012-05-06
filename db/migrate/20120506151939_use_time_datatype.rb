class UseTimeDatatype < ActiveRecord::Migration
  def up
    rename_column('events', :start_time, :old_start_time)
    rename_column('events', :end_time, :old_end_time)
    rename_column('weekly_events', :start_time, :old_start_time)
    rename_column('weekly_events', :end_time, :old_end_time)

    add_column('events', :start_time, :time)
    add_column('events', :end_time, :time)
    add_column('weekly_events', :start_time, :time)
    add_column('weekly_events', :end_time, :time)

    remove_column('events', :old_start_time)
    remove_column('events', :old_end_time)
    remove_column('weekly_events', :old_start_time)
    remove_column('weekly_events', :old_end_time)
  end

  def down
    rename_column('events', :start_time, :old_start_time)
    rename_column('events', :end_time, :old_end_time)
    rename_column('weekly_events', :start_time, :old_start_time)
    rename_column('weekly_events', :end_time, :old_end_time)

    add_column('events', :start_time, :string, :limit => 8)
    add_column('events', :end_time, :string, :limit => 8)
    add_column('weekly_events', :start_time, :string, :limit => 8)
    add_column('weekly_events', :end_time, :string, :limit => 8)

    remove_column('events', :old_start_time)
    remove_column('events', :old_end_time)
    remove_column('weekly_events', :old_start_time)
    remove_column('weekly_events', :old_end_time)
  end
end
