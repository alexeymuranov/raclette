class CreateTicketsPurchases < ActiveRecord::Migration
  def self.up
    create_table :tickets_purchases do |t|
      t.integer :member_id
      t.integer :tickets_number
      t.integer :ticket_book_id
      t.date :purchase_date

      t.timestamps
    end
  end

  def self.down
    drop_table :tickets_purchases
  end
end
