# Modues to be mixed into classes to group classes by their "types"

module Type

  module IndexedObjects  # for Hash, Array, etc

    def self.included(base)
      # The base class must have #[] instance method that behaves accordingly.
      # Check that a method named #[] is at least defined:
      raise unless base.method_defined? :[]
    end
  end
end