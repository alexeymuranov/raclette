require 'app_active_record_extensions/pseudo_columns'

module AbstractPerson  # NOTE:WIP
  def self.included(base)
    base.send(:include, PseudoColumns) unless
      base.include?(PseudoColumns)

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

    # Pseudo columns
    [ :last_name, :first_name, :name_title, :nickname_or_other, :email,
      :full_name, :ordered_full_name, :formatted_email
    ].each do |attr|
      base.add_pseudo_columns attr => Person.sql_for_columns[attr]
      base.add_pseudo_column_db_types attr => Person.column_db_types[attr]
    end
  end
end
