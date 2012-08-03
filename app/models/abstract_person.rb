require 'app_active_record_extensions/composite_attributes'

module AbstractPerson  # NOTE:WIP
  def self.included(base)
    base.send(:include, CompositeAttributes) unless
      base.include?(CompositeAttributes)

    # Associations
    base.belongs_to :person

    base.accepts_nested_attributes_for :person

    # Delegations
    base.delegate :last_name,
                  :first_name,
                  :name_title,
                  :nickname_or_other,
                  :birthyear,
                  :email,
                  :mobile_phone,
                  :home_phone,
                  :work_phone,
                  :personal_phone,
                  :primary_address,
                  :virtual_full_name,
                  :to => :person

    # Validations
    base.validates :person_id, :presence   => true,
                               :uniqueness => true

    # Scopes
    base.scope :default_order, base.joins(:person).merge(Person.default_order)

    # Composite attributes
    [ :last_name, :first_name, :name_title, :nickname_or_other, :email,
      :full_name, :ordered_full_name, :formatted_email
    ].each do |attr|
      base.add_composite_attributes attr => Person.sql_for_attributes[attr]
      base.add_composite_attribute_db_types attr => Person.attribute_db_types[attr]
    end
  end
end
