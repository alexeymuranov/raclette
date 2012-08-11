## encoding: UTF-8

module FilterMarkupHelper

  def filter_by_prefix_button_set(attr, prefixes, current_prefix, param_key_prefix='filter', html_options={})
    if current_prefix.nil?
      stripped_current_prefix = nil
    else
      stripped_current_prefix = current_prefix.sub(/\%+\z/, '')
    end

    key_name = "#{ param_key_prefix }[#{ attr }]"

    content_tag(:ul, html_options) do
      prefixes.inject(''.html_safe) { |html_output, prefix|
        if prefix == stripped_current_prefix
          html_class = 'current filtering_prefix'
          item_content = content_tag(:span, prefix)
        else
          html_class = 'filtering_prefix'
          item_content = button_tag(prefix, :name  => key_name,
                                            :value => prefix,
                                            :type  => :submit)
        end
        html_output << content_tag(:li, item_content, :class => html_class)
      }
    end
  end
end
