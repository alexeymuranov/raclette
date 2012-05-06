require 'test_helper'

class WeeklyEventTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: weekly_events
#
#  id                    :integer         not null, primary key
#  event_type            :string(32)      not null
#  title                 :string(64)      not null
#  lesson                :boolean         not null
#  week_day              :integer(1)      not null
#  start_time            :string(8)
#  duration              :integer(2)      default(60)
#  end_time              :string(8)
#  start_on              :date            not null
#  end_on                :date
#  location              :string(64)
#  address_id            :integer
#  lesson_supervision_id :integer
#  entry_fee_tickets     :integer(1)
#  over                  :boolean         default(FALSE), not null
#  description           :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

