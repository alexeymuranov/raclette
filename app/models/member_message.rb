## encoding: UTF-8

# == Schema Information
# Schema version: 20110618120707
#
# Table name: member_messages
#
#  id         :integer         not null, primary key
#  member_id  :integer         not null
#  content    :text            not null
#  created_on :date            not null
#  created_at :datetime
#  updated_at :datetime
#

class MemberMessage < ActiveRecord::Base

  attr_readonly :id, :member_id

  # attr_accessible( # :id,
                   # :member_id,
                   # :content,
                   # :created_on
                 # )  ## all attributes listed here

  # Associations:
  belongs_to :member, :inverse_of => :member_message

  # Validations:
  validates :member_id, :content, :created_on,
                :presence => true

  validates :content, :length => { :maximum => 1024 }

  validates :member_id, :uniqueness => true
end
