class CreateActivityPeriods < ActiveRecord::Migration
  def self.up
    create_table :activity_periods do |t|
      t.string :unique_title
      t.date :start_date
      t.integer :duration_months
      t.date :end_date
      t.boolean :over
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :activity_periods
  end
end
