class ApplicationJournalRecord < ActiveRecord::Base
  set_table_name :application_journal

  belongs_to :user, :inverse_of => :application_journal_records
end
