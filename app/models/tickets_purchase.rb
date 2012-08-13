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

  # Callbacks:
  before_validation :copy_tickets_number
  before_create     :increment_member_payed_tickets_count

  private

    def copy_tickets_number
      self.tickets_number ||= ticket_book.tickets_number
    end

    def increment_member_payed_tickets_count
      self.member.payed_tickets_count += tickets_number
      self.member.save!
    end

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

