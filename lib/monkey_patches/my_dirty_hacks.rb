# Standard classes are modified here

require 'set'
require 'assets/types'

class Object

  module MyDirtyHack

    def my_deep_value(*keys)
      obj = self
      obj = obj[keys.shift] until keys.empty? || obj.nil?
      obj
    end
  end

  include MyDirtyHack
end

class Hash
  include Type::IndexedObjects  # initially empty module, to declare the "type"

  module MyDirtyHack

    module ClassMethods
      def my_deep_set_or_array_to_hash(deep_enum)
        result = {}
        deep_enum = deep_enum.to_set if deep_enum.is_a?(Array)
        deep_enum = deep_enum.my_to_hash if deep_enum.is_a?(Set)
        deep_enum.each_pair do |key, value|
          if value.nil?
            result[key] = nil
          else
            result[key] = my_deep_set_or_array_to_hash(value)
          end
        end
        result.deep_dup
      end
    end

    def my_deep_except!(other_hash)
      other_hash.each_pair do |key, other_value|
        if has_key?(key)
          if other_value.nil?
            delete(key)
          else
            self[key].my_deep_except!(other_value)
          end
        end
      end
      self
    end

    def my_deep_except(other_hash)
      result = self.class.new
      each_pair do |key, value|
        if other_hash.has_key?(key)
          other_value = other_hash[key]
          result[key] = value.my_deep_except(other_value) unless other_value.nil?
        else
          result[key] = value
        end
      end
      result
    end

    def my_deep_filter!(filter)
      return self if filter.nil?
      each_pair do |key, value|
        if filter.has_key?(key)
          value.my_deep_filter!(filter[key]) if value.is_a?(Hash)
        else
          delete(key)
        end
      end
      self
    end

    def my_deep_filter(filter)
      return deep_dup if filter.nil?
      result = self.class.new
      each_pair do |key, value|
        result[key] = value.my_deep_filter(filter[key]) if filter.has_key?(key) && value.is_a?(Hash)
      end
      result
    end
  end

  include MyDirtyHack
  extend MyDirtyHack::ClassMethods
end

class Array
  include Type::IndexedObjects  # initially empty module, to declare the "type"
end

class Set

  module MyDirtyHack

    def my_to_hash
      hash = {}
      each { |element| hash[element] = nil }
      hash
    end
  end

  include MyDirtyHack
end

# class String  # XXX: redefining #to_a once caused a difficult to track bug!
#
#   module MyDirtyHack
#
#     def my_to_a
#       chars.to_a
#     end
#   end
#
#   include MyDirtyHack
# end
