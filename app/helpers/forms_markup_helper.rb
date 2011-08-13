## encoding: UTF-8

module FormsMarkupHelper

  def set_params_in_hidden_form_fields(hash)
    query_string = hash.except(:controller, :action, :utf8).to_query
    generated_html = ''.html_safe
    query_string.split(/[&;]+/).each do |single_option|
      unless single_option.blank?
        a = single_option.split('=', 2)
        generated_html += hidden_field_tag(a.first, a.last)
      end
    end
    generated_html
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
