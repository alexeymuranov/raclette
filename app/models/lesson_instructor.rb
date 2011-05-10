class LessonInstructor < ActiveRecord::Base

  attr_readonly :id, :lesson_supervision_id, :instructor_id

  # attr_accessible( # :id,
                   # :lesson_supervision_id,
                   # :instructor_id,
                   # :invited,
                   # :volunteer,
                   # :assistant
                 # )  ## all attributes listed here

  belongs_to :instructor, :inverse_of => :lesson_instructors

  belongs_to :lesson_supervision, :inverse_of => :lesson_instructors
end
