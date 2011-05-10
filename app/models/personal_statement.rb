class PersonalStatement < ActiveRecord::Base
  set_primary_key :person_id

  attr_readonly :id, :person_id

  # attr_accessible( # :id,
                   # :person_id,
                   # :birthday
                   # :accept_email_announcements,
                   # :volunteer,
                   # :volunteer_as,
                   # :preferred_language,
                   # :occupation,
                   # :remark
                 # )  ## all attributes listed here

  belongs_to :person, :inverse_of => :statement
end
