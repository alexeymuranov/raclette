## encoding: UTF-8

module FormsMarkupHelper

  # Originally based on http://marklunds.com/articles/one/314
  def spread_param_hash(hash, key_prefix = '')
    format_key = key_prefix.blank? ? lambda { |k| k.to_s } :
                                     lambda { |k| key_prefix + "[#{k}]" }
    flat_hash = {}
    hash.each do |k, v|
      k = format_key.call(k)
      if v.is_a?(Hash)
        flat_hash.merge!(spread_param_hash(v, k))
      else
        flat_hash[k] = v
      end
    end
    flat_hash
  end

  def hidden_field_tags_from_param_hash(hash, options = {})
    hidden_field_tags = []
    spread_param_hash(hash).each do |name, value|
      if value.is_a?(Array)
        name << '[]'
        value.each do |v|
          hidden_field_tags << hidden_field_tag(name, v, options)
        end
      else
        hidden_field_tags << hidden_field_tag(name, value, options)
      end
    end

    hidden_field_tags.join("\n").html_safe
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
