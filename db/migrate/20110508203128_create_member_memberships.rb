class CreateMemberMemberships < ActiveRecord::Migration
  def self.up
    create_table :member_memberships do |t|
      t.integer :member_id
      t.integer :membership_id
      t.date :obtained_on

      t.timestamps
    end
  end

  def self.down
    drop_table :member_memberships
  end
end
