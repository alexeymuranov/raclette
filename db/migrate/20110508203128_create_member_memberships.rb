class CreateMemberMemberships < ActiveRecord::Migration
  def self.up
    create_table :member_memberships do |t|
      t.integer :member_id
      t.integer :membership_id
      t.date    :obtained_on

      t.timestamps
    end

    add_index :member_memberships, [ :member_id, :membership_id ],
                  :unique => true
    add_index :member_memberships, :membership_id
    add_index :member_memberships, :obtained_on
  end

  def self.down
    drop_table :member_memberships
  end
end
