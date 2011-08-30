class Guest
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::AttributeMethods
  # include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :first_name, :last_name, :email, :phone, :note
  
  def initialize(attributes = {})
    @attributes = attributes || {}
    @first_name = @attributes[:first_name] || @first_name
    @last_name  = @attributes[:last_name]  || @last_name
    @email      = @attributes[:email]      || @email
    @phone      = @attributes[:phone]      || @phone
    @note       = @attributes[:note]       || @note
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
