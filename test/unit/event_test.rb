require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: events
#
#  id                    :integer         not null, primary key
#  event_type            :string(32)      not null
#  title                 :string(64)
#  locked                :boolean         default(FALSE), not null
#  lesson                :boolean         not null
#  date                  :date
#  start_time            :string(8)
#  duration_minutes      :integer(2)
#  end_time              :string(8)
#  location              :string(64)
#  address_id            :integer
#  weekly                :boolean         default(FALSE), not null
#  weekly_event_id       :integer
#  supervisors           :string(255)
#  lesson_supervision_id :integer
#  entry_fee_tickets     :integer(1)
#  member_entry_fee      :decimal(3, 1)
#  couple_entry_fee      :decimal(3, 1)
#  common_entry_fee      :decimal(3, 1)
#  over                  :boolean         default(FALSE), not null
#  reservations_count    :integer(2)      default(0)
#  entries_count         :integer(2)      default(0)
#  member_entries_count  :integer(2)      default(0)
#  tickets_collected     :integer(2)      default(0)
#  entry_fees_collected  :decimal(6, 1)   default(0.0)
#  description           :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

