require 'set'

module PseudoColumns
  def self.included(base_class)
    # NOTE: looks like a hack
    base_class.extend ClassMethods if base_class.ancestors.count(self) == 1
  end

  module ClassMethods
    def self.extended(base_class)
      base_class.send :initialize_pseudo_columns
    end

    # Callback
    def inherited(subclass)
      [ :@pseudo_column_names, :@sql_for_columns, :@column_db_types
      ].each do |var|
        subclass.instance_variable_set var, instance_variable_get(var).dup
      end
      super
    end

    # attr_reader :column_names

    # Provides SQL identifiers for attributes corresponding to columns
    # in the standard form "table_name"."column_name".
    # Can be extended in subclasses to include SQL expressions for
    # virtual columns.
    # attr_reader :sql_for_columns

    def add_pseudo_columns(sql_for_columns)
      @sql_for_columns.merge! sql_for_columns
      @pseudo_column_names.merge sql_for_columns.keys.map(&:to_s)
    end

    def sql_for_column(col)
      @sql_for_columns[col]
    end

    # Returns standard types (`:string`, `:integer`, etc.) for attributes
    # corresponding to columns by essentially calling
    # `#columns_hash[attribute].type`.
    # Can be extended in subclasses to virtual columns.
    attr_reader :column_db_types

    def add_pseudo_column_db_types(column_db_types)
      @column_db_types.merge! column_db_types
    end

    def column_db_type(col)
      @column_db_types[col]
    end

    # Cannot use `scope` with `lambda` here because `lambda` would bind
    # to the current ... scope (not in the above sense :)), in particular,
    # `self` would be `PseudoColumns` in all descendants.
    def with_pseudo_columns(*attributes)
      attributes.blank? ? scoped : select(with_pseudo_columns_sql(*attributes))
    end

    def pseudo_column?(name)
      @pseudo_column_names.include?(name.to_s)
    end

    private

      def initialize_pseudo_columns
        @pseudo_column_names = column_names.to_set
        @sql_for_columns = Hash.new { |hash, key|
          if col = columns_hash[key.to_s]
            hash[key] = %("#{ table_name }"."#{ col.name }")
          end
        }
        @column_db_types = Hash.new { |hash, key|
          if col = columns_hash[key.to_s]
            hash[key] = col.type
          end
        }
      end

      def pseudo_columns_sql(*attributes)
        attributes.delete_if { |attr| columns_hash[attr.to_s] }
        attributes.map{ |attr|
          "#{ @sql_for_columns[attr] } AS #{ attr.to_s }"
        }.join(', ')
      end

      def with_pseudo_columns_sql(*attributes)
        %("#{ table_name }".*, #{ pseudo_columns_sql(*attributes) })
      end

  end
end
