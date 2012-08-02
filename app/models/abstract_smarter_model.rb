module AbstractSmarterModel
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Provides SQL identifiers for attrubutes corresponding to columns
    # in the standard form "table_name"."column_name".
    # Can be extended in subclasses to include SQL expressions for
    # virtual columns.
    def sql_for_attributes
      @sql_for_attributes ||= Hash.new { |hash, key|
        if (key.is_a?(Symbol)) && (column = columns_hash[key.to_s])
          hash[key] = %("#{ table_name }"."#{ key.to_s }")
        else
          nil
        end
      }
    end

    def sql_for_attr(attr)
      sql_for_attributes[attr]
    end

    # Returns standard types (`:string`, `:integer`, etc.) for attrubutes
    # corresponding to columns by essentially calling
    # `#columns_hash[attribute].type`.
    # Can be extended in subclasses to virtual columns.
    def attribute_db_types
      @attribute_db_types ||= Hash.new { |hash, key|
        if (key.is_a?(Symbol)) && (column = columns_hash[key.to_s])
          hash[key] = column.type
        else
          nil
        end
      }
    end

    def attr_db_type(attr)
      attribute_db_types[attr]
    end

    def composite_attributes_sql(*attributes)
      attributes.delete_if { |attr| columns_hash[attr.to_s] }
      attributes.map{ |attr|
        "#{ sql_for_attributes[attr] } AS #{ attr.to_s }"
      }.join(', ')
    end

    def with_composite_attributes_sql(*attributes)
      %("#{ table_name }".*, #{ composite_attributes_sql(*attributes) })
    end

    # Cannot use `scope` with `lambda` here because `lambda` would bind
    # to the current ... scope (not in the above sense :)), in particular,
    # `self` would be `AbstractSmarterModel` in all descendants.
    def with_composite_attributes(*attributes)
      attributes.blank? ? scoped :
        select(with_composite_attributes_sql(*attributes))
    end
  end
end
