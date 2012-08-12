require 'test_helper'

class MemberShortHistoryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: member_short_histories
#
#  member_id                              :integer          not null, primary key
#  last_active_membership_expiration_date :date
#  prev_membership_expiration_date        :date             not null
#  prev_membership_type                   :string(32)       not null
#  prev_membership_duration_months        :integer          default(12), not null
#  created_at                             :datetime
#  updated_at                             :datetime
#

