require 'test_helper'

class EventCashierTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: event_cashiers
#
#  id          :integer         not null, primary key
#  event_id    :integer
#  name        :string(64)      not null
#  person_id   :integer
#  started_at  :datetime        not null
#  finished_at :datetime
#  created_at  :datetime
#  updated_at  :datetime
#

