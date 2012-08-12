require 'test_helper'

class Admin::SafeUserIPTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: admin_safe_user_ips
#
#  id           :integer          not null, primary key
#  known_ip_id  :integer          not null
#  user_id      :integer          not null
#  last_used_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

