module AbstractPerson  # NOTE:WIP
  def self.included(base)
    base.send(:include, AbstractSmarterModel)
    base.extend ClassMethods

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
                  :non_sql_full_name,
                  :to => :person

    # Validations
    base.validates :person_id, :presence => true, :uniqueness => true

    # Scopes
    base.scope :default_order, base.joins(:person).merge(Person.default_order)
  end

  module ClassMethods
    # Public class methods
    def sql_for_attributes  # Extends the one from AbstractSmarterModel
      unless @sql_for_attributes
        super

        [ :last_name, :first_name, :name_title, :nickname_or_other, :email,
          :full_name, :ordered_full_name, :formatted_email
        ].each do |attr|
          @sql_for_attributes[attr] = Person.sql_for_attributes[attr]
        end
      end
      @sql_for_attributes
    end

    def attribute_db_types  # Extends the one from AbstractSmarterModel
      unless @attribute_db_types
        super

        [ :last_name, :first_name, :name_title, :nickname_or_other, :email
        ].each do |attr|
          @attribute_db_types[attr] =
            "delegated_#{Person.columns_hash[attr.to_s].type.to_s}".to_sym
        end

        [ :full_name, :ordered_full_name, :formatted_email
        ].each do |attr|
          @attribute_db_types[attr] = :virtual_string
        end
      end
      @attribute_db_types
    end
  end
end
