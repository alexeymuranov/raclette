class CreateMembershipTypes < ActiveRecord::Migration
  def self.up
    create_table :membership_types do |t|
      t.string :unique_title
      t.boolean :active
      t.boolean :reduced
      t.boolean :unlimited
      t.integer :duration_months
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :membership_types
  end
end
