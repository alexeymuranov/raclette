class TicketsPurchase < ActiveRecord::Base

  has_one :payment, :as        => :payable,
                    :dependent => :nullify

  belongs_to :member, :inverse_of => :tickets_purchases

  belongs_to :ticket_book, :inverse_of => :tickets_purchases
end
