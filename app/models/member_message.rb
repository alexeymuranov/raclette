class MemberMessage < ActiveRecord::Base

  belongs_to :member, :inverse_of => :member_message
end
