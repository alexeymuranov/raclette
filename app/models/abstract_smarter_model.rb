module AbstractSmarterModel  # NOTE:WIP
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Provides SQL identifiers for attrubutes corresponding to columns
    # in the standard form "table_name"."column_name".
    # Can be extended in subclasses to include SQL expressions for
    # virtual or delegated attributes.
    def sql_for_attributes
      unless @sql_for_attributes
        @sql_for_attributes = Hash.new { |hash, key|
          if (key.class == Symbol) && (column = self.columns_hash[key.to_s])
            hash[key] = "\"#{self.table_name}\".\"#{key.to_s}\""
          else
            nil
          end
        }
      end
      @sql_for_attributes
    end

    # Returns standard types (`:string`, `:integer`, etc.) for attrubutes
    # corresponding to columns by essentially calling
    # `#columns_hash[attribute].type`.
    # Can be extended in subclasses to "virtual" types
    # (`:virtual_string`, `:delegated_integer`, etc.)
    # for virtual or delegated attributes.
    def attribute_db_types
      unless @attribute_db_types
        @attribute_db_types = Hash.new { |hash, key|
          if (key.class == Symbol) && (column = self.columns_hash[key.to_s])
            hash[key] = column.type
          else
            nil
          end
        }
      end
      @attribute_db_types
    end

    def named_virtual_attributes_sql(*attributes)
      attributes.delete_if { |attr| columns_hash[attr.to_s] }
      attributes.map{ |attr|
        "#{sql_for_attributes[attr]} AS #{attr.to_s}"
      }.join(', ')
    end

    def native_and_named_attributes_sql(*attributes)
      if attributes.blank?
        "\"#{table_name}\".*"
      else
        "\"#{table_name}\".*, #{named_virtual_attributes_sql(*attributes)}"
      end
    end
    
    # Cannot use `scope` with `lambda` here because `lambda` would bind
    # to the current ... scope (not in the above sense :)), in particular,
    # `self` would be `AbstractSmarterModel` in all descendants.
    def with_virtual_attributes(*attributes)
      select(native_and_named_attributes_sql(*attributes))  # a Relation
    end
  end
end
