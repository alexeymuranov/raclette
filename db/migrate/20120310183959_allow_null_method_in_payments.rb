class AllowNullMethodInPayments < ActiveRecord::Migration
  def up
    remove_index "payments", ["cancelled_and_reimbursed", "cancelled_on"]
    change_column :payments, :method, :string, :limit => 32, :null => true
    add_index "payments", ["cancelled_and_reimbursed", "cancelled_on"], :name => "index_payments_on_cancelled_and_reimbursed_and_cancelled_on"
  end

  def down
    remove_index "payments", ["cancelled_and_reimbursed", "cancelled_on"]
    change_column :payments, :method, :string, :limit => 32, :null => false
    add_index "payments", ["cancelled_and_reimbursed", "cancelled_on"], :name => "index_payments_on_cancelled_and_reimbursed_and_cancelled_on"
  end
end
