class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.integer :membership_type_id
      t.integer :activity_period_id
      t.decimal :price
      t.integer :members_count

      t.timestamps
    end
  end

  def self.down
    drop_table :memberships
  end
end
