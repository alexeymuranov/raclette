require 'test_helper'

class WeeklyEventTest < ActiveSupport::TestCase
  test "should build events" do
    weekly_event = weekly_events(:practica_du_jeudi)
    weekly_event.build_events
    weekly_event.save!
    assert_equal weekly_event.events.count, 54
  end
end

# == Schema Information
#
# Table name: weekly_events
#
#  id                    :integer          not null, primary key
#  event_type            :string(32)       not null
#  title                 :string(64)       not null
#  lesson                :boolean          not null
#  week_day              :integer          not null
#  start_time            :time(8)
#  end_time              :time(8)
#  start_on              :date             not null
#  end_on                :date
#  location              :string(64)
#  address_id            :integer
#  lesson_supervision_id :integer
#  entry_fee_tickets     :integer
#  over                  :boolean          default(FALSE), not null
#  description           :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  duration_minutes      :integer
#

