require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "should be able to initialize from a weekly event" do
    weekly_event = weekly_events(:practica_du_jeudi)
    event = Event.new(weekly_event)
    assert event.weekly?
    [ :event_type, :lesson,
      :start_time, :end_time, :duration_minutes,
      :location, :address,
      :lesson_supervision, :entry_fee_tickets
    ].each do |attr_name|
      assert_equal event.public_send(attr_name),
                   weekly_event.public_send(attr_name)
    end
  end

  test "Event.current should return a current event" do
    assert_equal Event.current, events(:current)
  end
end

# == Schema Information
#
# Table name: events
#
#  id                    :integer          not null, primary key
#  event_type            :string(32)       not null
#  title                 :string(64)
#  locked                :boolean          default(FALSE), not null
#  lesson                :boolean          not null
#  date                  :date
#  start_time            :time(8)
#  end_time              :time(8)
#  location              :string(64)
#  address_id            :integer
#  weekly                :boolean          default(FALSE), not null
#  weekly_event_id       :integer
#  supervisors           :string(255)
#  lesson_supervision_id :integer
#  entry_fee_tickets     :integer
#  member_entry_fee      :decimal(3, 1)
#  couple_entry_fee      :decimal(3, 1)
#  common_entry_fee      :decimal(3, 1)
#  over                  :boolean          default(FALSE), not null
#  reservations_count    :integer          default(0)
#  entries_count         :integer          default(0)
#  member_entries_count  :integer          default(0)
#  tickets_collected     :integer          default(0)
#  entry_fees_collected  :decimal(6, 1)    default(0.0)
#  description           :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  duration_minutes      :integer
#

