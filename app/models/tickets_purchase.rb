class TicketsPurchase < ActiveRecord::Base

  attr_readonly :id, :member_id, :tickets_number, :purchase_date

  # attr_accessible( # :id,
                   # :member_id,
                   # :ticket_book_id,
                   # :tickets_number,
                   # :purchase_date
                 # )  ## all attributes listed here

  has_one :payment, :as        => :payable,
                    :dependent => :nullify

  belongs_to :member, :inverse_of => :tickets_purchases

  belongs_to :ticket_book, :inverse_of => :tickets_purchases
end
