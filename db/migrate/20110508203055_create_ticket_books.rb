class CreateTicketBooks < ActiveRecord::Migration
  def self.up
    create_table :ticket_books do |t|
      t.integer :membership_type_id
      t.integer :tickets_number
      t.decimal :price

      t.timestamps
    end
  end

  def self.down
    drop_table :ticket_books
  end
end
