class SecretaryNote < ActiveRecord::Base

  belongs_to :something, :polymorphic => true
end
