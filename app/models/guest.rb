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
      public_send("#{name}=", value)
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
end
