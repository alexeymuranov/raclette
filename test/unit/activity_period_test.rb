require 'test_helper'

class ActivityPeriodTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: activity_periods
#
#  id              :integer         not null, primary key
#  unique_title    :string(64)      not null
#  start_date      :date            not null
#  duration_months :integer(1)      default(12), not null
#  end_date        :date            not null
#  over            :boolean         default(FALSE), not null
#  description     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

