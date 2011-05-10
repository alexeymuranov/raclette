class Instructor < ActiveRecord::Base
  set_primary_key :person_id

  attr_readonly :id, :person_id

  # attr_accessible( # :id,
                   # :person_id,
                   # :presentation,
                   # :photo,
                   # :employed_from,
                   # :employed_until
                 # )  ## all attributes listed here

  has_many :lesson_instructors, :dependent  => :destroy,
                                :inverse_of => :instructor

  has_many :lesson_supervisons, :through => :lesson_instructors

  belongs_to :person, :inverse_of => :instructor
end
