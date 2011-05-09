class CreateKnownIps < ActiveRecord::Migration
  def self.up
    create_table :known_ips do |t|
      t.string :ip,          :limit =>  15, :null => false
      t.string :description, :limit => 255

      t.timestamps
    end

    add_index :known_ips, :ip,
                  :unique => true
  end

  def self.down
    drop_table :known_ips
  end
end
