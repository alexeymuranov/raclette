class CreateEventCashiers < ActiveRecord::Migration
  def self.up
    create_table :event_cashiers do |t|
      t.integer :event_id
      t.string :name
      t.integer :person_id
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end

  def self.down
    drop_table :event_cashiers
  end
end
