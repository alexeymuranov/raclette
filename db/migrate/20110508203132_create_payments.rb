class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.string  :payable_type, :limit =>  32,                 :null => false
      t.integer :payable_id
      t.date    :date,                                        :null => false
      t.decimal :amount, :scale => 1, :precision => 4,        :null => false
      t.string  :method,       :limit =>  32,                 :null => false
      t.integer :revenue_account_id
      t.integer :payer_person_id
      t.boolean :cancelled_and_reimbursed, :default => false, :null => false
      t.date    :cancelled_on
      t.string  :note,         :limit => 255

      t.timestamps
    end

    add_index :payments, [ :payable_type, :payable_id ]
    add_index :payments, [ :payable_type, :date ]
    add_index :payments, :date
    add_index :payments, :revenue_account_id
    add_index :payments, :payer_person_id
    add_index :payments, [ :cancelled_and_reimbursed, :cancelled_on ]
  end

  def self.down
    drop_table :payments
  end
end
