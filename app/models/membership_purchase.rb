class MembershipPurchase < ActiveRecord::Base

  has_one :payment, :as        => :payable,
                    :dependent => :nullify

  has_many :accounted_guest_entries, :dependent  => :nullify,
                                     :inverse_of => :membership_purchase

  belongs_to :member, :inverse_of => :membership_purchases

  belongs_to :membership, :inverse_of => :membership_purchases
end
