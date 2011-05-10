class LessonSupervision < ActiveRecord::Base

  attr_readonly :id, :unique_names, :instructors_count

  # attr_accessible( # :id,
                   # :unique_names,
                   # :instructors_count,
                   # :comment
                 # )  ## all attributes listed here

  has_many :lesson_instructors, :dependent  => :destroy,
                                :inverse_of => :lesson_supervision

  has_many :instructors, :through => :lesson_instructors

  has_many :weekly_events, :dependent  => :nullify,
                           :inverse_of => :lesson_supervision

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :lesson_supervision
end
