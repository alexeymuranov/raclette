## encoding: UTF-8

class TicketsPurchase < ActiveRecord::Base

  attr_readonly :id, :member_id, :tickets_number, :purchase_date

  # Associations:
  has_many :payments, :as        => :payable,
                      :dependent => :nullify

  belongs_to :member, :inverse_of => :tickets_purchases

  belongs_to :ticket_book, :inverse_of => :tickets_purchases

  accepts_nested_attributes_for :payments

  # Validations:
  validates :member_id, :tickets_number, :purchase_date,
            :presence  => true

  validates :tickets_number, :inclusion => 1..1000

  validate :the_membership_must_be_acquired_already

  # Scopes:
  scope :last_12_hours, lambda {
    where("#{ table_name }.updated_at > ?", (Time.now - 12.hours).strftime("%F %T"))
  }
  scope :default_order, order("#{ table_name }.purchase_date DESC, "\
                              "#{ table_name }.updated_at DESC")

  # Callbacks:
  before_validation :copy_tickets_number

  private

    def the_membership_must_be_acquired_already
      membership = ticket_book.membership
      unless member.memberships.include?(membership)
        errors.add(:base,
                   I18n.t('model_validation_error_messages.ticket_purchase.membership_not_acquired',
                          :person_name      => member.virtual_full_name,
                          :membership_title => membership.virtual_title))
      end
    end

    def copy_tickets_number
      self.tickets_number ||= ticket_book.tickets_number
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

