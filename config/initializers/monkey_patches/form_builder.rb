# Be sure to restart your server when you modify this file.

# Created by Alexey in 2011-08-13.
# Based on http://davidsulc.com/blog/2011/05/01/self-marking-required-fields-in-rails-3/

class ActionView::Helpers::FormBuilder
  alias_method :orig_label, :label

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
    label_itself = self.orig_label(method, content, options, &block)

    if marks_arr == []
      label_itself
    else
      label_marks = %Q{<span class="label_marks">#{marks_arr.join}</span>}\
                      .html_safe
      label_itself + label_marks
    end
  end
end
