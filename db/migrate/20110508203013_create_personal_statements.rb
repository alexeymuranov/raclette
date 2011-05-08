class CreatePersonalStatements < ActiveRecord::Migration
  def self.up
    create_table :personal_statements, :primary_key => :person_id do |t|
      t.primary_key :person_id
      t.date        :birthday
      t.boolean     :accept_email_announcements
      t.boolean     :volunteer
      t.string      :volunteer_as
      t.string      :preferred_language
      t.string      :occupation
      t.string      :remark

      t.timestamps
    end

    # add_index :personal_statements, :person_id, :unique => true
    add_index :personal_statements, :accept_email_announcements
    add_index :personal_statements, :volunteer
  end

  def self.down
    drop_table :personal_statements
  end
end
