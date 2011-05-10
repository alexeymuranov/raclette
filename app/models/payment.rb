class Payment < ActiveRecord::Base

  attr_readonly :id, :payable_type, :date, :amount, :method

  # attr_accessible( # :id,
                   # :payable_type,
                   # :payable_id,
                   # :date,
                   # :amount,
                   # :method,
                   # :payer_person_id,
                   # :cancelled_and_reimbursed,
                   # :cancelled_on,
                   # :note
                 # )  ## all attributes listed here

  belongs_to :purchase, :foreign_key => :payable_id,
                        :polymorphic => true

  belongs_to :payer, :foreign_key => :payer_person_id,
                     :class_name  => :Person,
                     :inverse_of  => :payments
end
