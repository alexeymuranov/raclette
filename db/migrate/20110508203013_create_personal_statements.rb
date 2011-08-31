class CreatePersonalStatements < ActiveRecord::Migration
  def up
    create_table :personal_statements, :primary_key => :person_id do |t|
      t.primary_key :person_id
      t.date        :birthday
      t.boolean     :accept_email_announcements, :default => false
      t.boolean     :volunteer,                  :default => false
      t.string      :volunteer_as,       :limit => 255
      t.string      :preferred_language, :limit =>  32
      t.string      :occupation,         :limit =>  64
      t.string      :remark,             :limit => 255

      t.timestamps
    end

    # add_index :personal_statements, :person_id, :unique => true
    add_index :personal_statements, :accept_email_announcements
    add_index :personal_statements, :volunteer
  end

  def down
    drop_table :personal_statements
  end
end
