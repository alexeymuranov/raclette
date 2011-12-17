## encoding: UTF-8

class ApplicationJournalRecord < ActiveRecord::Base
  self.table_name = :application_journal

  attr_readonly :id, :action, :username, :user_id, :ip,
                :something_type, :something_id, :details, :generated_at

  # Associations:
  belongs_to :user, :inverse_of => :application_journal_records

  belongs_to :something, :polymorphic => true

  # Validations:
  validates :action, :username, :ip, :something_type, :generated_at,
                :presence => true

  validates :action, :length => { :maximum => 64 }

  validates :username, :length => { :maximum => 32 }

  validates :ip, :length => { :maximum => 15 }

  validates :something_type, :length => { :maximum => 32 }

  validates :details, :length    => { :maximum => 255 },
                      :allow_nil => true
end
# == Schema Information
#
# Table name: application_journal
#
#  id             :integer         not null, primary key
#  action         :string(64)      not null
#  username       :string(32)      not null
#  user_id        :integer
#  ip             :string(15)      not null
#  something_type :string(32)      not null
#  something_id   :integer
#  details        :string(255)
#  generated_at   :datetime        not null
#  created_at     :datetime
#  updated_at     :datetime
#

