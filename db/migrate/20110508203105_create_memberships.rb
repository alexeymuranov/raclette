class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :membership_type_id,                  :null => false
      t.integer :activity_period_id,                  :null => false
      t.decimal :price, :scale => 1, :precision => 4
      t.integer :members_count, :default => 0

      t.timestamps
    end

    add_index :memberships, [ :activity_period_id, :membership_type_id ],
                  :unique => true
    add_index :memberships, :membership_type_id
  end

  def self.down
    drop_table :memberships
  end
end
