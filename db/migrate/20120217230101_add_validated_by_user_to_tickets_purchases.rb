class AddValidatedByUserToTicketsPurchases < ActiveRecord::Migration
  def change
    add_column :tickets_purchases, :validated_by_user, :string, :limit => 32
  end
end
