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

    def deep_filter!(filter)
      return self if filter.nil?
      filter = Set.new(filter) if filter.is_a?(Array)
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
      return dup if filter.nil?
      filter = Set.new(filter) if filter.is_a?(Array)
      filter = filter.to_hash if filter.is_a?(Set)
      result = Hash::new
      each_pair do |key, value|
        result[key] = value.deep_filter(filter[key]) if filter.has_key?(key) && value.is_a?(Hash)
      end
      result
    end

    def to_set
      Set.new(keys)
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
