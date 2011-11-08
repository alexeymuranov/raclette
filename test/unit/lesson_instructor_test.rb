require 'test_helper'

class LessonInstructorTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: lesson_instructors
#
#  id                    :integer         not null, primary key
#  lesson_supervision_id :integer         not null
#  instructor_id         :integer         not null
#  invited               :boolean         default(FALSE), not null
#  volunteer             :boolean         default(FALSE), not null
#  assistant             :boolean         default(FALSE), not null
#  created_at            :datetime
#  updated_at            :datetime
#

