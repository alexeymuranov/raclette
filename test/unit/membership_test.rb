require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: memberships
#
#  id                  :integer         not null, primary key
#  membership_type_id  :integer         not null
#  activity_period_id  :integer         not null
#  initial_price       :decimal(4, 1)
#  current_price       :decimal(4, 1)
#  tickets_count_limit :integer
#  members_count       :integer         default(0)
#  created_at          :datetime
#  updated_at          :datetime
#

