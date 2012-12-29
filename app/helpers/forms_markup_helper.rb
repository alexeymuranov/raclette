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
        k = format_key[k]
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

    def attribute_field(attribute, column_type = nil, options = {}) # FIXME: WIP
      fail
      object = form_builder.object
      klass = object.class

      unless local_assigns.key? :column_type
        # It is assumed here that PseudoColumns module is included
        column_type = klass.column_db_type(attribute)
      end

      required = klass.attr_required?(attribute)
      input_html_options[:required] = 'required' if required

      editable = object.attr_editable?(attribute)

      select_from = klass.possible_values_of(attribute)
      select_from = nil unless select_from.respond_to?(:size)

      html_output = ''.html_safe

      html_output << content_tag(:div, :class => 'item field') do
        label_element = content_tag(:dt) do
          human_name = klass.human_attribute_name(attribute)

          case column_type
          when :boolean
            label_content = t('formats.attribute_name?', :attribute => human_name)
          else
            label_content = t('formats.attribute_name:', :attribute => human_name)
          end

          if editable
            label attribute, label_content
          else
            content_tag(:b, label_content)
          end
        end

        if editable
          if select_from
            input_element = content_tag(:dd, :class => 'list') do
              select attribute,
                     options_for_select(select_from,
                                        object.public_send(attribute)),
                     { :include_blank => !required },
                     input_html_options
            end
          else
            case column_type
            when :boolean
              input_element = content_tag(:dd, :class => 'boolean') do
                check_box attribute, input_html_options
              end
            when :integer
              input_element = content_tag(:dd, :class => 'number') do
                number_field attribute, input_html_options
              end
            when :date
              # Defined in my custom form builder
              input_element = content_tag(:dd, :class => 'date') do
                date_field attribute, input_html_options
              end
            when :datetime
              # Defined in my custom form builder
              input_element = content_tag(:dd, :class => 'datetime') do
                local_datetime_field attribute, input_html_options
              end
            when :time
              # Defined in my custom form builder
              input_element = content_tag(:dd, :class => 'time') do
                local_time_field attribute, input_html_options
              end
            when :text
              input_element = content_tag(:dd, :class => 'long_text') do
                text_area attribute, input_html_options
              end
            when :string
              case input_html_options[:type]
              when :email
                input_element = content_tag(:dd, :class => 'string email') do
                  email_field attribute, input_html_options
                end
              when :password
                input_element = content_tag(:dd, :class => 'string password') do
                  password_field attribute, input_html_options
                end
              else
                input_element = content_tag(:dd, :class => 'string') do
                  text_field attribute, input_html_options
                end
              end
            else
              input_element = content_tag(:dd, :class => 'boolean') do
                text_field attribute, input_html_options
              end
            end
          end
        else
          value = object.public_send(attribute)

          case column_type
          when :boolean
            input_element = content_tag(:dd, :class => 'boolean') do
              boolean_to_picto(value, 2) # size = 2
            end
          when :integer
            input_element = content_tag(:dd, :class => 'number') do
              value
            end
          when :date
            input_element = content_tag(:dd, :class => 'date') do
              l(value, :format => :long) if value
            end
          when :datetime
            input_element = content_tag(:dd, :class => 'datetime') do
              l(value, :format => :custom) if value
            end
          when :time
            input_element = content_tag(:dd, :class => 'time') do
              l(value, :format => :time_of_the_day) if value
            end
          else
            input_element = content_tag(:dd, :class => column_type) do
              value
            end
          end
        end

        label_element + input_element
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
