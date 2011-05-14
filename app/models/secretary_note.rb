class SecretaryNote < ActiveRecord::Base

  attr_readonly :id, :note_type, :something_type, :something_id, :created_on

  # attr_accessible( # :id,
                   # :note_type,
                   # :something_type,
                   # :something_id,
                   # :created_on
                   # :message,
                   # :message_updated_at
                 # )  ## all attributes listed here

  # Associations:
  belongs_to :something, :polymorphic => true

  # Validations:
  validates :note_type, :something_type, :something_id, :created_on,
            :message_updated_at,
                :presence => true

  validates :note_type, :something_type,
                :length => { :maximum => 32 }

  validates :message, :length    => { :maximum => 1024 },
                      :allow_nil => true

  validates :something_id,
                :uniqueness => { :scope => [ :note_type, :something_type ] }
end
