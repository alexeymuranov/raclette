## encoding: UTF-8

module FormsMarkupHelper

  # Originally based on http://marklunds.com/articles/one/314
  def param_name_value_pairs_from_nested_hash(nested_hash, key_prefix = '')
    format_key = if key_prefix.blank?
                   lambda { |k| k.to_s }
                 else
                   lambda { |k| "#{ key_prefix }[#{ k }]" }
                 end

    {}.tap do |flat_hash|
      nested_hash.each_pair do |k, v|
        k = format_key.(k)
        if v.is_a?(Hash)
          flat_hash.merge!(param_name_value_pairs_from_nested_hash(v, k))
        else
          flat_hash[k] = v
        end
      end
    end
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

    include ActionView::Helpers::TagHelper

    def date_field(method, options = {})
      ActionView::Helpers::InstanceTag.new(@object_name, method, @template,
        options.delete(:object)).to_input_field_tag('date', options)
    end

    def local_time_field(method, options = {})
      ActionView::Helpers::InstanceTag.new(@object_name, method, @template,
        options.delete(:object)).to_input_field_tag('time-local', options)
    end

    def local_datetime_field(method, options = {})
      ActionView::Helpers::InstanceTag.new(@object_name, method, @template,
        options.delete(:object)).to_input_field_tag('datetime-local', options)
    end

    def label(method, content_or_options = nil, options = {}, &block)
      if content_or_options && content_or_options.is_a?(Hash)
        options, content = content_or_options, nil
      else
        content = content_or_options
      end

      if options[:class]
        html_classes = options[:class].split(' ')
      else
        html_classes = []
      end

      marks = ''.html_safe

      klass = object.class

      # add a '*' after the field label if the field is required
      if klass.validators_on(method).map(&:class).
           include?(ActiveModel::Validations::PresenceValidator)
        marks << '*'.html_safe
        html_classes << 'required'
      end

      # add a '!' after the field label if the field will be readonly
      if klass.readonly_attributes.include?(method.to_s)
        marks << content_tag(:sup, '!'.html_safe)
        html_classes << 'readonly'
      end

      options[:class] = html_classes.join(' ') unless html_classes.empty?
      label_itself = super(method, content, options, &block)

      if marks.empty?
        label_itself
      else
        label_itself + content_tag(:span, marks, :class => 'label_marks')
      end
    end

    # def select_for_belongs_to(assoc_name, text_method, collection = nil,
    #                           options = {}, html_options = {})
    #   klass = object.class
    #   reflection = klass.reflect_on_association(assoc_name)
    #   foreign_key = reflection.foreign_key
    #   collection ||= reflection.klass
    #
    #   # Assume ActiveModelUtilities module was mixed into klass
    #   required = klass.attr_required?(foreign_key)
    #
    #   unless options.key?(:include_blank) || required
    #     options[:include_blank] = true
    #   end
    #
    #   collection_select(foreign_key, collection.all, :id, text_method,
    #                     options, html_options)
    # end

    # def select_for_habtm(assoc_name, text_method, collection = nil,
    #                      options = {}, html_options = {})
    #   klass = object.class
    #   reflection = klass.reflect_on_association(assoc_name)
    #   ids_attr_name = "#{ reflection.name.to_s.singularize }_ids"
    #   collection ||= reflection.klass
    #
    #   html_options[:multiple] = true
    #
    #   options.delete(:include_blank)
    #
    #   collection_select(ids_attr_name, collection.all, :id, text_method,
    #                     options, html_options)
    # end

    # Useful web page:
    # http://code.alexreisner.com/articles/form-builders-in-rails.html
    #
    # input_field_helpers = field_helpers - %w[label check_box radio_button fields_for hidden_field]
    # input_field_helpers.each do |helper|
    #   define_method helper do |field, *args|
    #     options = args.detect{ |a| a.is_a?(Hash) } || {}
    #     # decorate fields here
    #     super(field, *args)
    #   end
    # end
  end
end
