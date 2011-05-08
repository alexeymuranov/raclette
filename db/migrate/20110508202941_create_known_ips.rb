class CreateKnownIps < ActiveRecord::Migration
  def self.up
    create_table :known_ips do |t|
      t.string :ip
      t.string :description

      t.timestamps
    end

    add_index :known_ips, :ip,
                  :unique => true
  end

  def self.down
    drop_table :known_ips
  end
end
