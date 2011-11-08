require 'test_helper'

class MembershipTypeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: membership_types
#
#  id              :integer         not null, primary key
#  unique_title    :string(32)      not null
#  active          :boolean         default(FALSE), not null
#  reduced         :boolean         default(FALSE), not null
#  unlimited       :boolean         default(FALSE), not null
#  duration_months :integer(1)      default(12), not null
#  description     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

