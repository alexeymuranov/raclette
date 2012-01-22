# Standard classes are modified here

require 'set'
require 'assets/types'

class Object

  module MyDirtyHack

    def deep_value(*keys)
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

    def deep_except!(other_hash)
      other_hash = other_hash.to_set if other_hash.is_a?(Array)
      other_hash = other_hash.to_hash if other_hash.is_a?(Set)
      other_hash.each_pair do |key, other_value|
        if has_key?(key)
          if other_value.nil?
            delete(key)
          else
            self[key].deep_except!(other_value)
          end
        end
      end
      self
    end

    def deep_except(other_hash)
      other_hash = other_hash.to_set if other_hash.is_a?(Array)
      other_hash = other_hash.to_hash if other_hash.is_a?(Set)
      result = self.class.new
      each_pair do |key, value|
        if other_hash.has_key?(key)
          other_value = other_hash[key]
          result[key] = value.deep_except(other_value) unless other_value.nil?
        else
          result[key] = value
        end
      end
      result
    end

    def deep_filter!(filter)
      return self if filter.nil?
      filter = filter.to_set if filter.is_a?(Array)
      filter = filter.to_hash if filter.is_a?(Set)
      each_pair do |key, value|
        if filter.has_key?(key)
          value.deep_filter!(filter[key]) if value.is_a?(Hash)
        else
          delete(key)
        end
      end
      self
    end

    def deep_filter(filter)
      return deep_dup if filter.nil?
      filter = filter.to_set if filter.is_a?(Array)
      filter = filter.to_hash if filter.is_a?(Set)
      result = self.class.new
      each_pair do |key, value|
        result[key] = value.deep_filter(filter[key]) if filter.has_key?(key) && value.is_a?(Hash)
      end
      result
    end
  end

  include MyDirtyHack
end

class Array
  include Type::IndexedObjects  # initially empty module, to declare the "type"
end

class Set

  module MyDirtyHack

    def to_hash
      hash = Hash::new
      each { |element| hash[element] = nil }
      hash
    end
  end

  include MyDirtyHack
end

class String

  module MyDirtyHack

    def to_a
      chars.to_a
    end
  end

  include MyDirtyHack
end
