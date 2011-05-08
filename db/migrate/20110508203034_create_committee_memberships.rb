class CreateCommitteeMemberships < ActiveRecord::Migration
  def self.up
    create_table :committee_memberships do |t|
      t.integer :person_id
      t.string :function
      t.date :start_date
      t.date :end_date
      t.boolean :quit
      t.string :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :committee_memberships
  end
end
