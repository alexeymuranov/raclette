## encoding: UTF-8

module FormsMarkupHelper

  # Originally based on http://marklunds.com/articles/one/314
  def param_name_value_pairs_from_nested_hash(nested_hash, key_prefix = '')
    format_key = if key_prefix.blank?
                   lambda { |k| k.to_s }
                 else
                   lambda { |k| "#{ key_prefix }[#{ k }]" }
                 end

    flat_hash = {}
    nested_hash.each_pair do |k, v|
      k = format_key.(k)
      if v.is_a?(Hash)
        flat_hash.merge!(param_name_value_pairs_from_nested_hash(v, k))
      else
        flat_hash[k] = v
      end
    end
    flat_hash
  end

  def hidden_fields_from_nested_hash(hash, options = {})
    hidden_field_tags = []
    param_name_value_pairs_from_nested_hash(hash).each do |name, value|
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
      if klass.validators_on(method).map(&:class).
           include?(ActiveModel::Validations::PresenceValidator)
        marks_arr << '*'
        css_classes_arr << 'required'
      end

      # add a '!' after the field label if the field will be readonly
      if klass.readonly_attributes.include?(method.to_s)
        marks_arr << '<sup>!</sup>'
        css_classes_arr << 'readonly'
      end

      options[:class] = css_classes_arr.join(' ') unless css_classes_arr.empty?
      label_itself = super(method, content, options, &block)

      if marks_arr.empty?
        label_itself
      else
        label_marks = %(<span class="label_marks">#{ marks_arr.join }</span>).
                        html_safe
        label_itself + label_marks
      end
    end

    def select_for_belongs_to(assoc_name, collection, text_method,
                              options = {}, html_options = {})
      klass = object.class
      reflection = klass.reflect_on_association(assoc_name)
      foreign_key = reflection.foreign_key

      choices =
        collection.all.collect { |m| [m.public_send(text_method), m.id] }

      required =
        klass.validators_on(foreign_key).map(&:class).
              include?(ActiveModel::Validations::PresenceValidator)

      unless options.key?(:include_blank) || required
        options[:include_blank] = true
      end

      select(foreign_key, choices, options, html_options)
    end

    # FIXME:untested
    def select_for_habtm(assoc_name, collection, text_method,
                         options = {}, html_options = {})
      klass = object.class
      reflection = klass.reflect_on_association(assoc_name)
      ids_attr_name = "#{reflection.name.to_s.singularize}_ids"

      choices =
        collection.all.collect { |m| [m.public_send(text_method), m.id] }

      unless options.key?(:include_blank)
        options[:include_blank] = true
      end

      select("#{ ids_attr_name }[]", choices, options, html_options)
    end

    # Useful web page:
    # http://code.alexreisner.com/articles/form-builders-in-rails.html
    #
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
