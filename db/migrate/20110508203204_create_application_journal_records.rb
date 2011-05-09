class CreateApplicationJournalRecords < ActiveRecord::Migration
  def self.up
    create_table :application_journal do |t|
      t.string   :username, :limit =>  32
      t.integer  :user_id
      t.string   :ip,       :limit =>  15
      t.string   :action,   :limit =>  64
      t.string   :details,  :limit => 255
      t.datetime :generated_at, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :application_journal
  end
end
