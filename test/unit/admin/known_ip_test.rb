require 'test_helper'

class Admin::KnownIPTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: admin_known_ips
#
#  id          :integer          not null, primary key
#  ip          :string(15)       not null
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

