class CreateMembershipPurchases < ActiveRecord::Migration
  def self.up
    create_table :membership_purchases do |t|
      t.integer :member_id
      t.string  :membership_type
      t.date    :membership_expiration_date
      t.integer :membership_id
      t.date    :purchase_date

      t.timestamps
    end

    add_index :membership_purchases, [ :member_id, :membership_id ],
                  :unique => true
    add_index :membership_purchases, [ :membership_type,
                                       :membership_expiration_date ],
                  :name => 'index_membership_purchases_on'\
                           '_m_type_and_m_expiration_date'
    add_index :membership_purchases, :membership_expiration_date
    add_index :membership_purchases, :membership_id
    add_index :membership_purchases, :purchase_date
  end

  def self.down
    drop_table :membership_purchases
  end
end
