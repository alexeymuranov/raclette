## encoding: UTF-8

module FormsMarkupHelper

  # Creates a sequence of hidden inputs to store a flat hash of strings.
  def hidden_field_tags_from_flat_hash(hash, options = {})
    [].tap do |tag_array|
      hash.each_pair do |name, value|
        if value.is_a?(Enumerable)
          name = "#{ name }[]"
          value.each do |v|
            tag_array << hidden_field_tag(name, v, options)
          end
        else
          tag_array << hidden_field_tag(name, value, options)
        end
      end
    end.join("\n").html_safe
  end

  #--
  # This function is used in `hidden_field_tags_from_nested_hash`
  # Originally based on http://marklunds.com/articles/one/314.
  #++
  def flat_param_hash_from_nested_hash(nested_hash, key_prefix = '') # :nodoc:
    combine_key_with_prefix = if key_prefix.blank?
                                lambda { |k| "#{ k }" }
                              else
                                lambda { |k| "#{ key_prefix }[#{ k }]" }
                              end

    {}.tap do |flat_hash|
      nested_hash.each_pair do |key, value|
        combined_key = combine_key_with_prefix[key]
        if value.is_a?(Hash)
          flat_hash.merge!(flat_param_hash_from_nested_hash(value, combined_key))
        else
          flat_hash[combined_key] = value
        end
      end
    end
  end

  # Creates a sequence of hidden inputs to store a possibly nested hash
  # of strings.
  def hidden_field_tags_from_nested_hash(hash, options = {})
    hidden_field_tags_from_flat_hash(
      flat_param_hash_from_nested_hash(hash), options)
  end

  # Based on http://davidsulc.com/blog/2011/05/01/self-marking-required-fields-in-rails-3/
  class CustomFormBuilder < ActionView::Helpers::FormBuilder

    def date_field(method, options = {})
      ActionView::Helpers::InstanceTag.new(
        @object_name, method, @template, options.delete(:object)
      ).to_input_field_tag('date', options)
    end

    def local_time_field(method, options = {})
      ActionView::Helpers::InstanceTag.new(
        @object_name, method, @template, options.delete(:object)
      ).to_input_field_tag('time-local', options)
    end

    def local_datetime_field(method, options = {})
      ActionView::Helpers::InstanceTag.new(
        @object_name, method, @template, options.delete(:object)
      ).to_input_field_tag('datetime-local', options)
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

      # NOTE: assume that ActiveModelUtilities is included into the model class

      # add a '*' after the field label if the field is required
      if klass.attr_required?(method)
        marks << '*'.html_safe
        html_classes << 'required'
      end

      # add a '!' after the field label if the field will be readonly
      if klass.attr_readonly?(method)
        marks << @template.content_tag(:sup, '!'.html_safe)
        html_classes << 'readonly'
      end

      options[:class] = html_classes.join(' ') unless html_classes.empty?
      label_itself = super(method, content, options, &block)

      if marks.empty?
        label_itself
      else
        label_itself + @template.content_tag(:span, marks, :class => 'label_marks')
      end
    end

    def smart_input_field(method, column_type  = nil,
                                  html_options = {},
                                  options      = {})

      model = object.class

      column_type ||= model.column_db_type(method)

      required = model.attr_required?(method)
      html_options[:required] = 'required' if required

      editable = object.attr_editable?(method)

      select_from = model.possible_values_of(method)
      select_from = nil unless select_from.respond_to?(:size)

      if editable
        if select_from
          select method,
                 @template.options_for_select(select_from,
                                              object.public_send(method)),
                 { :include_blank => !required },
                 html_options
        else
          case column_type
          when :boolean
            check_box method, html_options
          when :integer
            number_field method, html_options
          when :date
            date_field method, html_options
          when :datetime
            local_datetime_field method, html_options
          when :time
            local_time_field method, html_options
          when :text
            text_area method, html_options
          when :string
            case html_options[:type]
            when :email
              email_field method, html_options
            when :password
              password_field method, html_options
            else
              text_field method, html_options
            end
          else
            text_field method, html_options
          end
        end
      else
        @template.formatted_attribute_value(object.public_send(method), column_type)
      end
    end

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
