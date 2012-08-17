require 'test_helper'

class WeeklyEventTest < ActiveSupport::TestCase
  setup do
    @weekly_practica_du_jeudi = weekly_events(:practica_du_jeudi)
  end

  test "should build events" do
    assert_difference('@weekly_practica_du_jeudi.events.count', 52) do
      @weekly_practica_du_jeudi.build_events
      @weekly_practica_du_jeudi.save!
    end
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

