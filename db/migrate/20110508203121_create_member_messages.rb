class CreateMemberMessages < ActiveRecord::Migration
  def up
    create_table :member_messages do |t|
      t.integer :member_id,  :null => false
      t.text    :content,    :null => false
      t.date    :created_on, :null => false

      t.timestamps
    end

    add_index :member_messages, :member_id,
                  :unique => true
    add_index :member_messages, :created_on
  end

  def down
    drop_table :member_messages
  end
end
