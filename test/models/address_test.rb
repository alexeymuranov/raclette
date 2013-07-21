require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: addresses
#
#  id             :integer          not null, primary key
#  names          :string(64)       not null
#  address_type   :string(32)
#  country        :string(32)       not null
#  city           :string(32)
#  post_code      :string(16)
#  street_address :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

