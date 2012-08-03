class SimpleFilter

  attr_reader   :filtering_values      # Hash
  attr_accessor :filtering_attributes  # Array

  def initialize
    @filtering_values = {}
    @filtering_attributes = []
  end

  def set_filtering_values_from_human_hash(human_filtering_values, klass)

    human_filtering_values.each do |attr, value|
      column_name = attr.to_s
      attr = column_name.to_sym

      if klass.include?(CompositeAttributes)
        filtering_column_type = klass.attribute_db_types[attr]
      else
        filtering_column_type = klass.columns_hash[column_name].type
      end

      case filtering_column_type
      when :string, :delegated_string, :virtual_string
        unless value.blank?
          @filtering_values[attr] = value.mb_chars.upcase.to_s.sub(/\%*\z/, '%')
        end
      when :boolean, :delegated_boolean
        unless value.nil?
          case value
          when /yes/i, /true/i, /t/i, 1, '1', true
            @filtering_values[attr] = true
          when /no/i, /false/i, /f/i, 0, '0', false
            @filtering_values[attr] = false
          end
        end
      when :integer, :delegated_integer, :virtual_integer
        minimum = value.try(:'[]', :min)
        minimum = minimum.blank? ? nil : minimum.to_i
        maximum = value.try(:'[]', :max)
        maximum = maximum.blank? ? nil : maximum.to_i
        if minimum || maximum
          @filtering_values[attr] = { :min => minimum,
                                      :max => maximum }
        end
      when :date, :delegated_date, :virtual_date
        start_date = value.try(:'[]', :from)
        start_date = start_date.blank? ? nil : start_date.to_date
        end_date = value.try(:'[]', :until)
        end_date = end_date.blank? ? nil : end_date.to_date
        if start_date || end_date
          @filtering_values[attr] = { :from  => start_date,
                                      :until => end_date }
        end
      end
    end
  end

  def do_filter(scoped_collection, filtering_values=nil,
                                   filtering_attributes=nil)
    klass = scoped_collection.klass
    table_name = klass.table_name
    @filtering_values = filtering_values || @filtering_values
    @filtering_attributes = filtering_attributes || @filtering_attributes\
                                                 || @filtering_values.keys

    @filtering_attributes.each do |attr|

      next if (filtering_value = @filtering_values[attr]).nil?

      column_name = attr.to_s

      if klass.include?(CompositeAttributes)
        filtering_column_type = klass.attribute_db_types[attr]
        column_sql            = klass.sql_for_attributes[attr]
      else
        filtering_column_type = klass.columns_hash[column_name].type
        column_sql            = "\"#{table_name}\".\"#{column_name}\""
      end

      unless filtering_column_type && column_sql
        if column = klass.columns_hash[column_name]
          filtering_column_type ||= column.type
          column_sql ||= "\"#{table_name}\".\"#{column_name}\""
        else
          next
        end
      end

      case filtering_column_type
      when :string, :delegated_string, :virtual_string
        scoped_collection = scoped_collection\
            .where("UPPER(#{column_sql}) LIKE ?", filtering_value)
      when :boolean, :delegated_boolean
        scoped_collection = scoped_collection\
            .where("#{column_sql} = ?", filtering_value)
      when :integer, :delegated_integer, :virtual_integer
        unless filtering_value[:min].nil?
          scoped_collection = scoped_collection\
              .where("#{column_sql} >= ?", filtering_value[:min])
        end
        unless filtering_value[:max].nil?
          scoped_collection = scoped_collection\
              .where("#{column_sql} <= ?", filtering_value[:max])
        end
      when :date, :delegated_date, :virtual_date
        unless filtering_value[:from].nil?
          scoped_collection = scoped_collection\
              .where("#{column_sql} >= ?", filtering_value[:from])
        end
        unless filtering_value[:until].nil?
          scoped_collection = scoped_collection\
              .where("#{column_sql} <= ?", filtering_value[:until])
        end
      end
    end

    scoped_collection
  end
end
