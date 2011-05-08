class CreateActivityPeriods < ActiveRecord::Migration
  def self.up
    create_table :activity_periods do |t|
      t.string  :unique_title
      t.date    :start_date
      t.integer :duration_months
      t.date    :end_date
      t.boolean :over
      t.string  :description

      t.timestamps
    end

    add_index :activity_periods, :unique_title,
                  :unique => true
    add_index :activity_periods, :start_date
    add_index :activity_periods, :duration_months
    add_index :activity_periods, :end_date
    add_index :activity_periods, [ :over, :end_date ]
  end

  def self.down
    drop_table :activity_periods
  end
end
