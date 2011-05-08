class CreateSafeUserIps < ActiveRecord::Migration
  def self.up
    create_table :safe_user_ips do |t|
      t.integer :known_ip_id
      t.integer :user_id
      t.datetime :last_connected_at

      t.timestamps
    end
  end

  def self.down
    drop_table :safe_user_ips
  end
end
