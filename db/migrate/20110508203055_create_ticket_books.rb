class CreateTicketBooks < ActiveRecord::Migration
  def up
    create_table :ticket_books do |t|
      t.integer :membership_type_id,                  :null => false
      t.integer :tickets_number, :limit => 2,         :null => false
      t.decimal :price, :scale => 1, :precision => 4, :null => false

      t.timestamps
    end

    add_index :ticket_books, [ :membership_type_id, :tickets_number ],
                  :unique => true
  end

  def down
    drop_table :ticket_books
  end
end
