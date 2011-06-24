## encoding: UTF-8

# == Schema Information
# Schema version: 20110618120707
#
# Table name: secretary_notes
#
#  id                 :integer         not null, primary key
#  note_type          :string(32)      not null
#  something_type     :string(32)      not null
#  something_id       :integer
#  created_on         :date            not null
#  message            :text
#  message_updated_at :datetime        not null
#  created_at         :datetime
#  updated_at         :datetime
#

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
