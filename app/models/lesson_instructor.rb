class LessonInstructor < ActiveRecord::Base

  belongs_to :instructor, :inverse_of => :lesson_instructors

  belongs_to :lesson_supervision, :inverse_of => :lesson_instructors
end
