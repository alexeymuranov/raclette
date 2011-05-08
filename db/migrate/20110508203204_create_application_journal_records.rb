class CreateApplicationJournalRecords < ActiveRecord::Migration
  def self.up
    create_table :application_journal do |t|
      t.string :username
      t.integer :user_id
      t.string :ip
      t.string :action
      t.string :details
      t.datetime :generated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :application_journal
  end
end
