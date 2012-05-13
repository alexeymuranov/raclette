## encoding: UTF-8

class LessonInstructor < ActiveRecord::Base

  attr_readonly :id, :lesson_supervision_id, :instructor_id

  # Associations:
  belongs_to :instructor, :inverse_of => :lesson_instructors

  belongs_to :lesson_supervision, :inverse_of => :lesson_instructors

  # Validations:
  validates :lesson_supervision_id, :instructor_id,
            :presence => true

  validates :instructor_id,
            :uniqueness => { :scope => :lesson_supervision_id }
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

