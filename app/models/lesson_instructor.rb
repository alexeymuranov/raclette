## encoding: UTF-8

# == Schema Information
# Schema version: 20110618120707
#
# Table name: lesson_instructors
#
#  id                    :integer         not null, primary key
#  lesson_supervision_id :integer         not null
#  instructor_id         :integer         not null
#  invited               :boolean         not null
#  volunteer             :boolean         not null
#  assistant             :boolean         not null
#  created_at            :datetime
#  updated_at            :datetime
#

class LessonInstructor < ActiveRecord::Base

  attr_readonly :id, :lesson_supervision_id, :instructor_id

  # attr_accessible( # :id,
                   # :lesson_supervision_id,
                   # :instructor_id,
                   # :invited,
                   # :volunteer,
                   # :assistant
                 # )  ## all attributes listed here

  # Associations:
  belongs_to :instructor, :inverse_of => :lesson_instructors

  belongs_to :lesson_supervision, :inverse_of => :lesson_instructors

  # Validations:
  validates :lesson_supervision_id, :instructor_id,
                :presence => true

  validates :instructor_id,
                :uniqueness => { :scope => :lesson_supervision_id }
end
