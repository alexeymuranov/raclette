require 'test_helper'

class MemberEntryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: member_entries
#
#  id             :integer         not null, primary key
#  member_id      :integer         not null
#  guests_invited :integer         default(0)
#  tickets_used   :integer(1)      default(0), not null
#  created_at     :datetime
#  updated_at     :datetime
#

