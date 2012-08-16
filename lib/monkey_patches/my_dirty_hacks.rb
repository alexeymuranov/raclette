# Standard classes are modified here

require 'set'
require 'types'

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
      def my_deep_collection_to_hash(deep_enum)
        result = {}
        unless deep_enum.is_a?(Hash)
          deep_enum = deep_enum.to_set unless deep_enum.is_a?(Set)
          deep_enum = deep_enum.my_to_hash
        end
        deep_enum.each_pair do |key, value|
          result[key] = value.is_a?(Enumerable) ? my_deep_collection_to_hash(value) : value
        end
        result.deep_dup
      end
    end

    # Returns a new hash with keys and nested keys indicated by +key_hash+ removed.
    # Example:
    #
    #   h = { :a => 1, :b => { :c => 2, :d => 3 }, :e => 4 }
    #   kh = { :a => true, :b => { :c => true } }
    #   h.deep_remove(kh)
    #   # => { :b => { :d => 3}, :e => 4 }
    def my_deep_remove(key_hash)
      new_hash = self.class.new
      each_pair do |k,v|
        unless key_hash.key?(k) && ov = key_hash[k]
          new_hash[k] = v.is_a?(Hash) ? v.deep_dup : v
        else
          new_hash[k] = v.deep_remove(ov) if ov.is_a?(Hash)
        end
      end
      new_hash
    end

    # Returns a new hash with keys and nested keys indicated by +key_hash+ removed.
    # Modifies the receiver in place.
    def my_deep_remove!(key_hash)
      key_hash.each_pair do |k,ov|
        if ov
          if ov.is_a?(Hash)
            self[k].deep_remove!(ov)
          else
            delete(k)
          end
        end
      end
      self
    end
    # Returns a new hash where only keys and nested keys indicated by +key_hash+ are kept.
    # Example:
    #
    #   h = { :a => 1, :b => { :c => 2, :d => 3 }, :e => 4 }
    #   kh = { :a => true, :b => { :c => true } }
    #   h.deep_filter(kh)
    #   # => { :a => 1, :b => { :c => 2} }
    def my_deep_filter(key_hash)
      new_hash = self.class.new
      each_pair do |k,v|
        if ov = key_hash[k]
          new_hash[k] = ov.is_a?(Hash) ? v.my_deep_filter(ov) : (v.is_a?(Hash) ? v.deep_dup : v)
        end
      end
      new_hash
    end

    # Returns a new hash where only keys and nested keys indicated by +key_hash+ are kept.
    # Modifies the receiver in place.
    def my_deep_filter!(key_hash)
      each_pair do |k,v|
        if ov = key_hash[k]
          v.my_deep_filter!(ov) if ov.is_a?(Hash)
        else
          delete(k)
        end
      end
      self
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
      each { |element| hash[element] = true }
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
