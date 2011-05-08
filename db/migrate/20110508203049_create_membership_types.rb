class CreateMembershipTypes < ActiveRecord::Migration
  def self.up
    create_table :membership_types do |t|
      t.string  :unique_title
      t.boolean :active
      t.boolean :reduced
      t.boolean :unlimited
      t.integer :duration_months
      t.string  :description

      t.timestamps
    end

    add_index :membership_types, :unique_title,
                  :unique => true
    add_index :membership_types, [ :active, :reduced, :unlimited,
                                   :duration_months ],
                  :name   => 'index_membership_types_on'\
                             '_a_and_r_and_u_and_duration_m',
                  :unique => true
    add_index :membership_types, :duration_months
  end

  def self.down
    drop_table :membership_types
  end
end
