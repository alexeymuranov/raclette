require 'test_helper'

class WeeklyEventSuspensionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: weekly_event_suspensions
#
#  id              :integer          not null, primary key
#  weekly_event_id :integer          not null
#  suspend_from    :date             not null
#  suspend_until   :date             not null
#  explanation     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

