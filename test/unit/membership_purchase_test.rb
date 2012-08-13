require 'test_helper'

class MembershipPurchaseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
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

