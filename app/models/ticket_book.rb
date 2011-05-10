class TicketBook < ActiveRecord::Base

  attr_readonly :id, :membership_type_id, :tickets_number

  # attr_accessible( # :id,
                   # :membership_type_id,
                   # :tickets_number,
                   # :price
                 # )  ## all attributes listed here

  has_many :tickets_purchases, :dependent  => :nullify,
                               :inverse_of => :ticket_book

  belongs_to :membership_type, :inverse_of => :ticket_books
end
