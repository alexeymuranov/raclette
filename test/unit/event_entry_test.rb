require 'test_helper'

class EventEntryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: event_entries
#
#  id                     :integer         not null, primary key
#  participant_entry_type :string(32)      not null
#  participant_entry_id   :integer
#  event_title            :string(64)      not null
#  date                   :date            not null
#  event_id               :integer
#  person_id              :integer
#  created_at             :datetime
#  updated_at             :datetime
#

