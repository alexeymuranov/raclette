class TicketBook < ActiveRecord::Base

  has_many :tickets_purchases, :dependent  => :nullify,
                               :inverse_of => :ticket_book

  belongs_to :membership_type, :inverse_of => :ticket_books
end
