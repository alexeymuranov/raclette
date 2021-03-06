## encoding: UTF-8

require 'app_active_record_extensions/pseudo_columns'

class TicketBook < ActiveRecord::Base
  include PseudoColumns
  include AbstractHumanizedModel

  # To use number_to_currency
  include ActionView::Helpers::NumberHelper # NOTE: weird???

  attr_readonly :id, :membership_id, :tickets_number

  # Associations:
  def self.init_associations
    belongs_to :membership, :inverse_of => :ticket_books

    has_many :tickets_purchases, :dependent  => :nullify,
                                 :inverse_of => :ticket_book
  end

  init_associations

  # Validations:
  validates :membership_id, :tickets_number, :price,
            :presence => true

  validates :price, :numericality => { :greater_than => 0 }

  validates :tickets_number,
            :uniqueness => { :scope => :membership_id }

  # Scopes:
  scope :default_order, lambda {
    order("#{ table_name }.tickets_number ASC")
  }

  # Public instance methods
  # Non-SQL virtual attributes
  def virtual_long_title
    "#{ tickets_number } (#{ membership.virtual_title })"\
    " : #{ number_to_currency(price, :unit => '€') }"
  end
end

# == Schema Information
#
# Table name: ticket_books
#
#  id                 :integer          not null, primary key
#  membership_id      :integer          not null
#  tickets_number     :integer          not null
#  price              :decimal(4, 1)    not null
#  created_at         :datetime
#  updated_at         :datetime
#

