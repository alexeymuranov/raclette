require 'test_helper'

class EventEntryReservationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: event_entry_reservations
#
#  id                      :integer          not null, primary key
#  event_id                :integer          not null
#  people_number           :integer          default(1), not null
#  names                   :string(64)       not null
#  member_id               :integer
#  previous_guest_entry_id :integer
#  contact_email           :string(255)
#  contact_phone           :string(32)
#  amount_payed            :decimal(3, 1)    default(0.0), not null
#  cancelled               :boolean          default(FALSE), not null
#  note                    :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

