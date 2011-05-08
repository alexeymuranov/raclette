class CreateMembershipPurchases < ActiveRecord::Migration
  def self.up
    create_table :membership_purchases do |t|
      t.integer :member_id
      t.string :membership_type
      t.date :membership_expiration_date
      t.integer :membership_id
      t.date :purchase_date

      t.timestamps
    end
  end

  def self.down
    drop_table :membership_purchases
  end
end
