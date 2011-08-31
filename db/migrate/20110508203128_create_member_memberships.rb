class CreateMemberMemberships < ActiveRecord::Migration
  def up
    create_table :member_memberships do |t|
      t.integer :member_id,     :null => false
      t.integer :membership_id, :null => false
      t.date    :obtained_on,   :null => false

      t.timestamps
    end

    add_index :member_memberships, [ :member_id, :membership_id ],
                  :unique => true
    add_index :member_memberships, :membership_id
    add_index :member_memberships, :obtained_on
  end

  def down
    drop_table :member_memberships
  end
end
