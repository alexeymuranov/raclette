class LessonSupervision < ActiveRecord::Base

  has_many :lesson_instructors, :dependent  => :destroy,
                                :inverse_of => :lesson_supervision

  has_many :instructors, :through => :lesson_instructors

  has_many :weekly_events, :dependent  => :nullify,
                           :inverse_of => :lesson_supervision

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :lesson_supervision
end
