require 'test_helper'

class PersonalStatementTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: personal_statements
#
#  person_id                  :integer         not null, primary key
#  birthday                   :date
#  accept_email_announcements :boolean         default(FALSE)
#  volunteer                  :boolean         default(FALSE)
#  volunteer_as               :string(255)
#  preferred_language         :string(32)
#  occupation                 :string(64)
#  remark                     :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#

