class MembershipPurchase < ActiveRecord::Base

  attr_readonly :id, :member_id, :membership_type,
                :membership_expiration_date, :purchase_date

  # attr_accessible( # :id,
                   # :member_id,
                   # :membership_type,
                   # :membership_expiration_date,
                   # :membership_id,
                   # :purchase_date
                 # )  ## all attributes listed here

  has_one :payment, :as        => :payable,
                    :dependent => :nullify

  has_many :accounted_guest_entries, :dependent  => :nullify,
                                     :inverse_of => :membership_purchase

  belongs_to :member, :inverse_of => :membership_purchases

  belongs_to :membership, :inverse_of => :membership_purchases
end
