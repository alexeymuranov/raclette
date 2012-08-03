module CompositeAttributes
  def self.included(base)
    # NOTE: looks like a hack
    if base.ancestors.count(self) == 1
      base.extend ClassMethods
      base.send :initialize_composite_attributes
    end
  end

  module ClassMethods
    # Callback
    def inherited(subclass)
      subclass.instance_variable_set :@sql_for_attributes, self.sql_for_attributes.dup
      subclass.instance_variable_set :@attribute_db_types, self.attribute_db_types.dup
      super
    end

    # Provides SQL identifiers for attributes corresponding to columns
    # in the standard form "table_name"."column_name".
    # Can be extended in subclasses to include SQL expressions for
    # virtual columns.
    attr_reader :sql_for_attributes

    def add_composite_attributes(sql_for_attributes)
      @sql_for_attributes ||= Hash.new { |hash, key|
        if col = columns_hash[key.to_s]
          hash[key] = %("#{ table_name }"."#{ col.name }")
        end
      }
      @sql_for_attributes.merge! sql_for_attributes
    end

    # Returns standard types (`:string`, `:integer`, etc.) for attributes
    # corresponding to columns by essentially calling
    # `#columns_hash[attribute].type`.
    # Can be extended in subclasses to virtual columns.
    attr_reader :attribute_db_types

    def add_composite_attribute_db_types(attribute_db_types)
      @attribute_db_types ||= Hash.new { |hash, key|
        if col = columns_hash[key.to_s]
          hash[key] = col.type
        end
      }
      @attribute_db_types.merge! attribute_db_types
    end

    # Cannot use `scope` with `lambda` here because `lambda` would bind
    # to the current ... scope (not in the above sense :)), in particular,
    # `self` would be `CompositeAttributes` in all descendants.
    def with_composite_attributes(*attributes)
      attributes.blank? ? scoped :
        select(with_composite_attributes_sql(*attributes))
    end

    private

      def initialize_composite_attributes
        @sql_for_attributes ||= Hash.new { |hash, key|
          if col = columns_hash[key.to_s]
            hash[key] = %("#{ table_name }"."#{ col.name }")
          end
        }
        @attribute_db_types ||= Hash.new { |hash, key|
          if col = columns_hash[key.to_s]
            hash[key] = col.type
          end
        }
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

  end
end
