class MemberEntry < ActiveRecord::Base

  attr_readonly :id, :member_id

  # attr_accessible( # :id,
                   # :member_id,
                   # :guests_invited,
                   # :tickets_used
                 # )  ## all attributes listed here

  has_one :event_entry, :as        => :participant_entry,
                        :dependent => :nullify

  belongs_to :member, :inverse_of => :member_entries
end
