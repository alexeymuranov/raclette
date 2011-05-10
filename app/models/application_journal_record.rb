class ApplicationJournalRecord < ActiveRecord::Base
  set_table_name :application_journal

  attr_readonly :id, :username, :ip, :action, :details, :generated_at

  # attr_accessible( # :id,
                   # :username,
                   # :user_id,
                   # :ip,
                   # :action,
                   # :details,
                   # :generated_at
                 # )  ## all attributes listed here

  belongs_to :user, :inverse_of => :application_journal_records
end
