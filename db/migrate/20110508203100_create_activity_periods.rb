class CreateActivityPeriods < ActiveRecord::Migration
  def up
    create_table :activity_periods do |t|
      t.string  :unique_title,    :limit =>  64, :null => false
      t.date    :start_date,                     :null => false
      t.integer :duration_months, :limit =>   1,
                       :default => 12,           :null => false
      t.date    :end_date,                       :null => false
      t.boolean :over, :default => false,        :null => false
      t.string  :description,     :limit => 255

      t.timestamps
    end

    add_index :activity_periods, :unique_title,
                  :unique => true
    add_index :activity_periods, :start_date
    add_index :activity_periods, :duration_months
    add_index :activity_periods, :end_date
    add_index :activity_periods, [ :over, :end_date ]
  end

  def down
    drop_table :activity_periods
  end
end
