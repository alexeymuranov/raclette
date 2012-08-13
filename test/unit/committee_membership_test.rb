require 'test_helper'

class CommitteeMembershipTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: committee_memberships
#
#  id         :integer          not null, primary key
#  person_id  :integer          not null
#  function   :string(64)       not null
#  start_date :date             not null
#  end_date   :date
#  quit       :boolean          default(FALSE), not null
#  comment    :string(255)
#  created_at :datetime
#  updated_at :datetime
#

