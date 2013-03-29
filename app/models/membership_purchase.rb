## encoding: UTF-8

class MembershipPurchase < ActiveRecord::Base

  attr_readonly :id, :member_id, :membership_type,
                :membership_expiration_date, :purchase_date

  # Associations:
  def self.init_associations
    belongs_to :member, :inverse_of => :membership_purchases

    belongs_to :membership, :inverse_of => :membership_purchases

    has_many :payments, :as        => :payable,
                        :dependent => :nullify

    has_many :accounted_guest_entries, :dependent  => :nullify,
                                       :inverse_of => :membership_purchase

    accepts_nested_attributes_for :payments
  end

  init_associations

  # Scopes:
  scope :last_12_hours, lambda {
    where("#{ table_name }.updated_at > ?", (Time.now - 12.hours).strftime("%F %T"))
  }
  scope :default_order, order("#{ table_name }.purchase_date DESC, "\
                              "#{ table_name }.updated_at DESC")

  # Validations:
  validates :member_id, :membership_type, :membership_expiration_date,
            :purchase_date,
            :presence => true

  validates :membership_type, :length => { :maximum => 32 }

  validates :membership_id, :uniqueness => { :scope => :member_id },
                            :allow_nil  => true
  # Callbacks:
  before_validation :copy_membership_type_and_expiration_date

  private

    def copy_membership_type_and_expiration_date
      self.membership_type ||= membership.membership_type.unique_title
      self.membership_expiration_date ||= membership.end_date
    end

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

