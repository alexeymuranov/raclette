class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :membership_type_id
      t.integer :activity_period_id
      t.decimal :price
      t.integer :members_count

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
