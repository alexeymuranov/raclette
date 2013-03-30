require 'set'

class SimpleRelationFilter
  attr_reader   :model                 # Class
  attr_accessor :filtering_values      # Hash
  attr_accessor :filtering_attributes  # Array

  def initialize(model)
    @model = model
    @filtering_values = {}
    @filtering_attributes = []
  end

  # def update(filtering_values, filtering_attributes = nil)
  #   @filtering_values.update(filtering_values)
  #   @filtering_attributes += filtering_attributes || @filtering_values.keys
  #   @filtering_attributes.uniq!
  # end

  def to_scope

    model_scope = @model.scoped

    table_name = @model.table_name

    @filtering_attributes.each do |attr|

      filtering_value = @filtering_values[attr]

      next if filtering_value.nil?

      column_name = attr.to_s

      if @model.include?(PseudoColumns)
        filtering_column_type = @model.column_db_type(attr)
        column_sql            = @model.sql_for_column(attr)
      else
        filtering_column_type = @model.columns_hash[column_name].type
        column_sql            = "\"#{ table_name }\".\"#{ column_name }\""
      end

      case filtering_column_type
      when :string
        case filtering_value
        when Set
          model_scope =
            model_scope.where("#{ column_sql } IN (?)", filtering_value)
        else
          model_scope =
            model_scope.where("#{ column_sql } LIKE ?", filtering_value)
        end

      when :boolean
        model_scope =
          model_scope.where("#{ column_sql } = ?", filtering_value)

      when :integer
        case filtering_value
        when Hash
          if filtering_value.key?(:min)
            unless filtering_value[:min] == -Float::INFINITY
              model_scope =
                model_scope.where("#{ column_sql } >= ?", filtering_value[:min])
            end
          end
          if filtering_value.key?(:max)
            unless filtering_value[:max] == Float::INFINITY
              model_scope =
                model_scope.where("#{ column_sql } <= ?", filtering_value[:max])
            end
          end
        when Set
          model_scope =
            model_scope.where("#{ column_sql } IN (?)", filtering_value)
        when Range
          unless filtering_value.first == -Float::INFINITY
            model_scope =
              model_scope.where("#{ column_sql } >= ?", filtering_value.first)
          end
          unless filtering_value.last == Float::INFINITY
            model_scope =
              if filtering_value.exclude_end?
                model_scope.where("#{ column_sql } < ?", filtering_value.last)
              else
                model_scope.where("#{ column_sql } <= ?", filtering_value.last)
              end
          end
        else
          model_scope =
            model_scope.where("#{ column_sql } = ?", filtering_value)
        end

      when :date
        case filtering_value
        when Hash
          if filtering_value.key?(:from)
            model_scope =
              model_scope.where("#{ column_sql } >= ?", filtering_value[:from])
          end
          if filtering_value.key?(:until)
            model_scope =
              model_scope.where("#{ column_sql } <= ?", filtering_value[:until])
          end
        when Set
          model_scope =
            model_scope.where("#{ column_sql } IN (?)", filtering_value)
        when Range
          unless filtering_value.first == -Float::INFINITY
            model_scope =
              model_scope.where("#{ column_sql } >= ?", filtering_value.first)
          end
          unless filtering_value.last == Float::INFINITY
            model_scope =
              if filtering_value.exclude_end?
                model_scope.where("#{ column_sql } < ?", filtering_value.last)
              else
                model_scope.where("#{ column_sql } <= ?", filtering_value.last)
              end
          end
        else
          model_scope =
            model_scope.where("#{ column_sql } = ?", filtering_value)
        end
      end
    end

    model_scope
  end

  def filtering_attributes_as_simple_nested_hash

    filtering_simple_hash = {}

    @filtering_attributes.each do |attr|

      filtering_value = @filtering_values[attr]

      next if filtering_value.nil?

      filtering_column_type = if @model.include?(PseudoColumns)
                                @model.column_db_type(attr)
                              else
                                @model.columns_hash[column_name].type
                              end

      case filtering_column_type
      when :string
        case filtering_value
        when Set
          filtering_simple_hash[attr] = filtering_value.to_a
        else
          filtering_simple_hash[attr] = filtering_value
        end

      when :boolean
        filtering_simple_hash[attr] = filtering_value

      when :integer
        case filtering_value
        when Hash
          filtering_simple_hash[attr] = {}
          if filtering_value.key?(:min)
            unless filtering_value[:min] == -Float::INFINITY
              filtering_simple_hash[attr][:min] = filtering_value[:min]
            end
          end
          if filtering_value.key?(:max)
            unless filtering_value[:max] == Float::INFINITY
              filtering_simple_hash[attr][:max] = filtering_value[:max]
            end
          end
        when Set
          filtering_simple_hash[attr] = filtering_value.to_a
        when Range
          filtering_simple_hash[attr] = {}
          unless filtering_value.first == -Float::INFINITY
            filtering_simple_hash[attr][:min] = filtering_value.first
          end
          unless filtering_value.last == Float::INFINITY
            filtering_simple_hash[attr][:max] = filtering_value.last
          end
        else
          filtering_simple_hash[attr] = filtering_value
        end

      when :date
        case filtering_value
        when Hash
          filtering_simple_hash[attr] = {}
          if filtering_value.key?(:from)
            filtering_simple_hash[attr][:from] = filtering_value[:from]
          end
          if filtering_value.key?(:until)
            filtering_simple_hash[attr][:until] = filtering_value[:until]
          end
        when Set
          filtering_simple_hash[attr] = filtering_value.to_a
        when Range
          filtering_simple_hash[attr] = {}
          unless filtering_value.first == -Float::INFINITY
            filtering_simple_hash[attr][:from] = filtering_value.first
          end
          unless filtering_value.last == Float::INFINITY
            filtering_simple_hash[attr][:until] = filtering_value.last
          end
        else
          filtering_simple_hash[attr] = filtering_value
        end
      end
    end

    filtering_simple_hash
  end
end
