class CreateKnownIps < ActiveRecord::Migration
  def self.up
    create_table :known_ips do |t|
      t.string :ip
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :known_ips
  end
end
