class CreateCommitteeMemberships < ActiveRecord::Migration
  def self.up
    create_table :committee_memberships do |t|
      t.integer :person_id
      t.string  :function
      t.date    :start_date
      t.date    :end_date
      t.boolean :quit
      t.string  :comment

      t.timestamps
    end

    add_index :committee_memberships, :person_id
    add_index :committee_memberships, :start_date
    add_index :committee_memberships, :end_date
    add_index :committee_memberships, [ :quit, :end_date ]
  end

  def self.down
    drop_table :committee_memberships
  end
end
