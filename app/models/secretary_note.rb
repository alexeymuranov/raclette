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

  belongs_to :something, :polymorphic => true
end
