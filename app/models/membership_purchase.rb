## encoding: UTF-8

class MembershipPurchase < ActiveRecord::Base

  attr_readonly :id, :member_id, :membership_type,
                :membership_expiration_date, :purchase_date

  # Associations:
  has_many :payments, :as        => :payable,
                      :dependent => :nullify

  has_many :accounted_guest_entries, :dependent  => :nullify,
                                     :inverse_of => :membership_purchase

  belongs_to :member, :inverse_of => :membership_purchases

  belongs_to :membership, :inverse_of => :membership_purchases

  # Validations:
  validates :member_id, :membership_type, :membership_expiration_date,
            :purchase_date,
            :presence => true

  validates :membership_type, :length => { :maximum => 32 }

  validates :membership_id, :uniqueness => { :scope => :member_id },
                            :allow_nil  => true
end

# == Schema Information
#
# Table name: membership_purchases
#
#  id                         :integer          not null, primary key
#  member_id                  :integer          not null
#  membership_type            :string(32)       not null
#  membership_expiration_date :date             not null
#  membership_id              :integer
#  purchase_date              :date             not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  validated_by_user          :string(32)
#

