class Guest
  include ActiveModel::Validations
  include ActiveModel::Conversion
  # include ActiveModel::AttributeMethods
  # include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :first_name, :last_name, :email, :phone, :note

  # Validations:
  validates :first_name, :presence => true

  validates :first_name, :last_name,
            :length => { :maximum => 32 }

  validates :email, :length       => { :maximum => 255 },
                    :email_format => true,
                    :allow_nil    => true

  validates :phone, :length    => { :maximum => 32 },
                    :allow_nil => true

  validates :note, :length    => { :maximum => 255 },
                   :allow_nil => true

  # Public instance methods
  def initialize(attributes = {})
    @attributes = {}
    attributes.each_pair do |name, value|
      name = name.to_sym
      public_send("#{ name }=", value)
      @attributes[name] = public_send(name)
    end unless attributes.nil?
  end

  def attributes
    @attributes
  end

  def persisted?
    false
  end

  def self.readonly_attributes
    []
  end

  # Transactions
  def attend_event(event, fee_payed       = event.common_entry_fee,
                          inviting_member = nil)

    event_entry_attributes = { :event => event }

    if fee_payed && fee_payed != 0
      payment_attributes = { :amount => fee_payed,
                             :date   => event.date }
      event_entry_attributes[:payment_attributes] = payment_attributes
    end

    guest_entry_attributes =
      attributes.merge(:inviting_member        => inviting_member,
                       :event_entry_attributes => event_entry_attributes)

    GuestEntry.create(guest_entry_attributes)
  end
end
