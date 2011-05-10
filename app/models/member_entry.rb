class MemberEntry < ActiveRecord::Base

  has_one :event_entry, :as        => :participant_entry,
                        :dependent => :nullify

  belongs_to :member, :inverse_of => :member_entries
end
