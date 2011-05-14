class CreateAdminKnownIps < ActiveRecord::Migration
  def self.up
    create_table :admin_known_ips do |t|
      t.string :ip,          :limit =>  15, :null => false
      t.string :description, :limit => 255

      t.timestamps
    end

    add_index :admin_known_ips, :ip,
                  :unique => true
  end

  def self.down
    drop_table :admin_known_ips
  end
end
