class CreateSafeUserIps < ActiveRecord::Migration
  def self.up
    create_table :safe_user_ips do |t|
      t.integer  :known_ip_id, :null => false
      t.integer  :user_id,     :null => false
      t.datetime :last_signed_in_at

      t.timestamps
    end

    add_index :safe_user_ips, :known_ip_id
    add_index :safe_user_ips, [ :user_id, :known_ip_id ],
                  :unique => true
  end

  def self.down
    drop_table :safe_user_ips
  end
end
