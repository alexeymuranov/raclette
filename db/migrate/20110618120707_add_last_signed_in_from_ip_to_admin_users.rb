class AddLastSignedInFromIpToAdminUsers < ActiveRecord::Migration
  def self.up
    add_column :admin_users, :last_signed_in_from_ip, :string, :limit => 15
  end

  def self.down
    remove_column :admin_users, :last_signed_in_from_ip
  end
end
