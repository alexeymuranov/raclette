## encoding: UTF-8

module FormsMarkupHelper

  # Based on: http://marklunds.com/articles/one/314
  def flatten_hash(hash = params, ancestor_names = [])
    flat_hash = {}
    hash.each do |k, v|
      names = Array.new(ancestor_names)
      names << k
      if v.is_a?(Hash)
        flat_hash.merge!(flatten_hash(v, names))
      else
        key = flat_hash_key(names)
        key += "[]" if v.is_a?(Array)
        flat_hash[key] = v
      end
    end

    flat_hash
  end

  def flat_hash_key(names)
    names = Array.new(names)
    name = names.shift.to_s.dup
    names.each do |n|
      name << "[#{n}]"
    end
    name
  end

  def hash_as_hidden_fields(hash)
    hidden_fields = []
    flatten_hash(hash).each do |name, value|
      value = [value] if !value.is_a?(Array)
      value.each do |v|
        hidden_fields << hidden_field_tag(name, v.to_s, :id => nil)
      end
    end

    hidden_fields.join("\n").html_safe
  end

  # My wrapper:
  def set_params_in_hidden_form_fields(hash = params)
    hash_as_hidden_fields(hash.except(:controller,
                                      :action,
                                      :utf8,
                                      :_method,
                                      :authenticity_token,
                                      :commit))
  end

  # Based on http://davidsulc.com/blog/2011/05/01/self-marking-required-fields-in-rails-3/
  class CustomFormBuilder < ActionView::Helpers::FormBuilder

    def label(method, content_or_options = nil, options = {}, &block)
      if content_or_options && content_or_options.class == Hash
        content = nil
        options = content_or_options
      else
        content = content_or_options
      end

      if options[:class]
        css_classes_arr = options[:class].split(' ')
      else
        css_classes_arr = []
      end

      marks_arr = []

      klass = object.class

      # add a '*' after the field label if the field is required
      if klass.validators_on(method).map(&:class).include?\
           ActiveModel::Validations::PresenceValidator
        marks_arr << '*'
        css_classes_arr << 'required'
      end

      # add a '!' after the field label if the field will be readonly
      if klass.readonly_attributes.include?(method.to_s)
        marks_arr << '<sup>!</sup>'
        css_classes_arr << 'readonly'
      end

      options[:class] = css_classes_arr.join(' ') unless css_classes_arr == []
      label_itself = super(method, content, options, &block)

      if marks_arr == []
        label_itself
      else
        label_marks = %Q{<span class="label_marks">#{marks_arr.join}</span>}\
                        .html_safe
        label_itself + label_marks
      end
    end

    # input_field_helpers = field_helpers - %w(label check_box radio_button fields_for hidden_field)
    # input_field_helpers.each do |helper|
    #   define_method helper do |field, *args|
    #     options = args.detect{ |a| a.is_a?(Hash) } || {}
    #     # decorate fields here
    #     super(field, *args)
    #   end
    # end
  end

  ActionView::Base.default_form_builder = CustomFormBuilder

end
