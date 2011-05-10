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

  # Associations:
  belongs_to :person, :inverse_of => :statement

  # Validations:
  validates :person_id, :presence => true

  validates :volunteer_as, :remark,
                :length    => { :maximum => 255 },
                :allow_nil => true

  validates :preferred_language, :length    => { :maximum => 32 },
                                 :allow_nil => true

  validates :occupation, :length    => { :maximum => 64 },
                         :allow_nil => true

  validates :person_id, :uniqueness => true
end
