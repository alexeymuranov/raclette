class CreateMembershipTypes < ActiveRecord::Migration
  def up
    create_table :membership_types do |t|
      t.string  :unique_title,        :limit =>  32, :null => false
      t.boolean :active,    :default => false,       :null => false
      t.boolean :reduced,   :default => false,       :null => false
      t.boolean :unlimited, :default => false,       :null => false
      t.integer :duration_months,     :limit =>   1,
                            :default => 12,          :null => false
      t.string  :description,         :limit => 255

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

  def down
    drop_table :membership_types
  end
end
