## encoding: UTF-8

class EventCashier < ActiveRecord::Base

  attr_readonly :id, :name, :started_at

  # Associations:
  belongs_to :event, :inverse_of => :cashiers

  belongs_to :person, :inverse_of => :event_cashiers

  # Validations:
  validates :name, :started_at,
                :presence => true

  validates :name, :length => { :maximum => 64 }

  # Scopes:
  scope :default_order, order('name ASC, event_id DESC, finished_at DESC')
end
# == Schema Information
#
# Table name: event_cashiers
#
#  id          :integer         not null, primary key
#  event_id    :integer
#  name        :string(64)      not null
#  person_id   :integer
#  started_at  :datetime        not null
#  finished_at :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

