## encoding: UTF-8

class MemberMessage < ActiveRecord::Base

  attr_readonly :id, :member_id

  # Associations:
  belongs_to :member, :inverse_of => :member_message

  # Validations:
  validates :member_id, :content, :created_on,
            :presence => true

  validates :content, :length => { :maximum => 1024 }

  validates :member_id, :uniqueness => true
end
# == Schema Information
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

