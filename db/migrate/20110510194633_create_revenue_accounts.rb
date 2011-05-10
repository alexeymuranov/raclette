class CreateRevenueAccounts < ActiveRecord::Migration
  def self.up
    create_table :revenue_accounts do |t|
      t.string  :unique_title, :limit =>  64, :null => false
      t.boolean :locked, :default => false,   :null => false
      t.integer :activity_period_id
      t.date    :opened_on
      t.date    :closed_on
      t.boolean :main,   :default => false,   :null => false
      t.decimal :amount, :scale => 2, :precision => 7,
                         :default => 0,       :null => false
      t.date    :amount_updated_on
      t.string  :description,  :limit => 255

      t.timestamps
    end

    add_index :revenue_accounts, :unique_title,
                  :unique => true
    add_index :revenue_accounts, [ :locked, :opened_on ]
    add_index :revenue_accounts, [ :locked, :closed_on ]
    add_index :revenue_accounts, :activity_period_id
    add_index :revenue_accounts, :opened_on
    add_index :revenue_accounts, :closed_on
  end

  def self.down
    drop_table :revenue_accounts
  end
end
