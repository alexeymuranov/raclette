class AddValidatedByUserToMembershipPurchases < ActiveRecord::Migration
  def change
    add_column :membership_purchases, :validated_by_user, :string, :limit => 32
  end
end
