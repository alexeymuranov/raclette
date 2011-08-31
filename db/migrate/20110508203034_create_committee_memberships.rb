class CreateCommitteeMemberships < ActiveRecord::Migration
  def up
    create_table :committee_memberships do |t|
      t.integer :person_id,               :null => false
      t.string  :function, :limit =>  64, :null => false
      t.date    :start_date,              :null => false
      t.date    :end_date
      t.boolean :quit, :default => false, :null => false
      t.string  :comment,  :limit => 255

      t.timestamps
    end

    add_index :committee_memberships, :person_id
    add_index :committee_memberships, :start_date
    add_index :committee_memberships, :end_date
    add_index :committee_memberships, [ :quit, :end_date ]
  end

  def down
    drop_table :committee_memberships
  end
end
