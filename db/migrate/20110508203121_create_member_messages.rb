class CreateMemberMessages < ActiveRecord::Migration
  def self.up
    create_table :member_messages do |t|
      t.integer :member_id
      t.text    :content
      t.date    :created_on

      t.timestamps
    end

    add_index :member_messages, :member_id,
                  :unique => true
    add_index :member_messages, :created_on
  end

  def self.down
    drop_table :member_messages
  end
end
