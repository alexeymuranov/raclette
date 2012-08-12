require 'test_helper'

class GuestEntryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: guest_entries
#
#  id                            :integer          not null, primary key
#  first_name                    :string(32)       not null
#  last_name                     :string(32)
#  inviting_member_id            :integer
#  previous_entry_id             :integer
#  toward_membership_purchase_id :integer
#  email                         :string(255)
#  phone                         :string(32)
#  note                          :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#

