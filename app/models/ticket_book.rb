## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'
require 'app_active_record_extensions/pseudo_columns'

class TicketBook < ActiveRecord::Base
  include Filtering
  include Sorting

  include PseudoColumns
  include AbstractHumanizedModel

  # To use number_to_currency
  include ActionView::Helpers::NumberHelper # NOTE: weird???

  attr_readonly :id, :membership_type_id, :tickets_number

  # Associations:
  has_many :tickets_purchases, :dependent  => :nullify,
                               :inverse_of => :ticket_book

  belongs_to :membership_type, :inverse_of => :ticket_books

  # Validations:
  validates :membership_type_id, :tickets_number, :price,
            :presence => true

  validates :price, :numericality => { :greater_than => 0 }

  validates :tickets_number,
                :uniqueness => { :scope => :membership_type_id }

  # Scopes:
  scope :default_order, order('tickets_number ASC')

  # Public instance methods
  # Non-SQL virtual attributes
  def virtual_long_title
    "#{ tickets_number } (#{ membership_type.unique_title })"\
    " : #{ number_to_currency(price, :unit => '€') }"
  end
end

# == Schema Information
#
# Table name: ticket_books
#
#  id                 :integer          not null, primary key
#  membership_type_id :integer          not null
#  tickets_number     :integer          not null
#  price              :decimal(4, 1)    not null
#  created_at         :datetime
#  updated_at         :datetime
#

