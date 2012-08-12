require 'test_helper'

class ApplicationJournalRecordTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: application_journal
#
#  id             :integer          not null, primary key
#  action         :string(64)       not null
#  username       :string(32)       not null
#  user_id        :integer
#  ip             :string(15)       not null
#  something_type :string(32)       not null
#  something_id   :integer
#  details        :string(255)
#  generated_at   :datetime         not null
#  created_at     :datetime
#  updated_at     :datetime
#

