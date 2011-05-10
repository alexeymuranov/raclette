class EventEntry < ActiveRecord::Base

  has_one :payment, :as        => :payable,
                    :dependent => :nullify

  belongs_to :person, :inverse_of => :event_entries

  belongs_to :event, :inverse_of => :event_entries

  belongs_to :participant_entry, :polymorphic => true,
                                 :dependent   => :destroy
end
