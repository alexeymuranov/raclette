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

  # Associations:
  belongs_to :user, :inverse_of => :application_journal_records

  # Validations:
  validates :generated_at, :presence => true

  validates :username, :length    => { :maximum => 32 },
                       :allow_nil => true

  validates :ip, :length    => { :maximum => 15 },
                 :allow_nil => true

  validates :action, :length    => { :maximum => 64 },
                     :allow_nil => true

  validates :details, :length    => { :maximum => 255 },
                      :allow_nil => true
end
