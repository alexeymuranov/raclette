class CreateEventCashiers < ActiveRecord::Migration
  def up
    create_table :event_cashiers do |t|
      t.integer  :event_id
      t.string   :name, :limit => 64, :null => false
      t.integer  :person_id
      t.datetime :started_at,         :null => false
      t.datetime :finished_at

      t.timestamps
    end

    add_index :event_cashiers, :event_id
    add_index :event_cashiers, :name
    add_index :event_cashiers, :person_id
    add_index :event_cashiers, :started_at
    add_index :event_cashiers, :finished_at
  end

  def down
    drop_table :event_cashiers
  end
end
