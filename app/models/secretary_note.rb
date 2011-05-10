class SecretaryNote < ActiveRecord::Base

  attr_readonly :id, :note_type, :something_type, :something_id,
                :message_updated_at

  # attr_accessible( # :id,
                   # :note_type,
                   # :message,
                   # :something_type,
                   # :something_id,
                   # :message_updated_at
                 # )  ## all attributes listed here

  # Associations:
  belongs_to :something, :polymorphic => true

  # Validations:
  validates :note_type, :something_type, :something_id, :message_updated_at,
                :presence => true

  validates :note_type, :something_type,
                :length => { :maximum => 32 }

  validates :message, :length    => { :maximum => 255 },
                      :allow_nil => true

  validates :something_id,
                :uniqueness => { :scope => [ :note_type, :something_type ] }
end
