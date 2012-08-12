## encoding: UTF-8

class TicketsPurchase < ActiveRecord::Base

  attr_readonly :id, :member_id, :tickets_number, :purchase_date

  # Associations:
  has_many :payments, :as        => :payable,
                      :dependent => :nullify

  belongs_to :member, :inverse_of => :tickets_purchases

  belongs_to :ticket_book, :inverse_of => :tickets_purchases

  # Validations:
  validates :member_id, :tickets_number, :purchase_date,
            :presence  => true

  validates :tickets_number, :inclusion => 1..1000
end

# == Schema Information
#
# Table name: tickets_purchases
#
#  id                :integer          not null, primary key
#  member_id         :integer          not null
#  tickets_number    :integer          not null
#  ticket_book_id    :integer
#  purchase_date     :date             not null
#  created_at        :datetime
#  updated_at        :datetime
#  validated_by_user :string(32)
#

