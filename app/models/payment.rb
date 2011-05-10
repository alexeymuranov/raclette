class Payment < ActiveRecord::Base

  belongs_to :purchase, :foreign_key => :payable_id,
                        :polymorphic => true

  belongs_to :payer, :foreign_key => :payer_person_id,
                     :class_name  => :Person,
                     :inverse_of  => :payments
end
