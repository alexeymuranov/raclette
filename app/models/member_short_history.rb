class MemberShortHistory < ActiveRecord::Base
  set_primary_key :member_id

  belongs_to :member, :inverse_of => :short_history
end
