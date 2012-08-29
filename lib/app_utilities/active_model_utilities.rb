# My idea: utility is a class mixin that is based completely
# on the existing interface, and that only adds instance or class level instance
# variables for memoizing.

require 'set'

# NOTE: due to memoizing, this module methods can only be used after the model class is completely defined.
module ActiveModelUtilities
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def readonly_attributes
      @readonly_attributes ||= super.to_set
    end

    def validator_classes_on(attr)
      attr = attr.to_s
      @validator_classes_on ||= {}
      @validator_classes_on[attr] ||= validators_on(attr).map(&:class).to_set
    end

    def attr_required?(attr)
      attr = attr.to_s
      @attr_required ||= {}
      if @attr_required.key?(attr)
        @attr_required[attr]
      else
        @attr_required[attr] = validator_classes_on(attr).include?(
          ActiveModel::Validations::PresenceValidator)
      end
    end

    def attr_readonly?(attr)
      attr = attr.to_s
      readonly_attributes.include?(attr.to_s)
    end

    def possible_values_of(attr)
      attr = attr.to_s
      @possible_values_of ||= {}
      return @possible_values_of[attr] if @possible_values_of.key?(attr)

      @inclusion_validator_on ||= {}
      if @inclusion_validator_on.key?(attr)
        inclusion_validator = @inclusion_validator_on[attr]
      else
        inclusion_validator = validators_on(attr).find { |v|
          v.is_a?(ActiveModel::Validations::InclusionValidator) }
        @inclusion_validator_on[attr] = inclusion_validator
      end
      @possible_values_of[attr] =
        inclusion_validator ? inclusion_validator.options[:in] : nil
    end
  end

  def attr_editable?(attr)
    # NOTE: #new_record? is defined only for ActiveRecord
    !self.class.attr_readonly?(attr) || new_record?
  end
end
