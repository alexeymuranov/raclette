class CreateAdminSafeUserIps < ActiveRecord::Migration
  def self.up
    create_table :admin_safe_user_ips do |t|
      t.integer  :known_ip_id, :null => false
      t.integer  :user_id,     :null => false
      t.datetime :last_signed_in_at

      t.timestamps
    end

    add_index :admin_safe_user_ips, :known_ip_id
    add_index :admin_safe_user_ips, [ :user_id, :known_ip_id ],
                  :unique => true
  end

  def self.down
    drop_table :admin_safe_user_ips
  end
end
