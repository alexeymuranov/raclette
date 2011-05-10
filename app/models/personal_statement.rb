class PersonalStatement < ActiveRecord::Base
  set_primary_key :person_id

  belongs_to :person, :inverse_of => :statement
end
