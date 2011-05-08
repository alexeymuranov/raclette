class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.string :payable_type
      t.integer :payable_id
      t.date :date
      t.decimal :amount
      t.string :method
      t.integer :payer_person_id
      t.boolean :cancelled_and_reimbursed
      t.date :cancelled_on
      t.string :note

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
