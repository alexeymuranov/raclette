class CreateTicketsPurchases < ActiveRecord::Migration
  def self.up
    create_table :tickets_purchases do |t|
      t.integer :member_id
      t.integer :tickets_number
      t.integer :ticket_book_id
      t.date    :purchase_date

      t.timestamps
    end

    add_index :tickets_purchases, :member_id
    add_index :tickets_purchases, :ticket_book_id
    add_index :tickets_purchases, :purchase_date
  end

  def self.down
    drop_table :tickets_purchases
  end
end
