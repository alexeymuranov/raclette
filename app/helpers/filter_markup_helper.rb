## encoding: UTF-8

module FilterMarkupHelper

  def filter_by_prefix(attr, prefixes, current_prefix, param_key_prefix='filter', html_options={})
    if current_prefix.nil?
      stripped_current_prefix = nil
    else
      stripped_current_prefix = current_prefix.sub(/\%+\z/, '')
    end

    key_name = "#{ param_key_prefix }[#{ attr }]"
    saved_params = params.except(key_name).merge(:button => 'filter')

    form_tag(nil, :method => :get) do
      hidden_fields_from_nested_hash(saved_params) << content_tag(:ul) do
        prefixes.inject(''.html_safe) { |html_output, pref|
          if pref == stripped_current_prefix
            html_class = 'current filtering_prefix'
            item_content = content_tag(:span, pref)
          else
            html_class = 'filtering_prefix'
            item_content = button_tag(pref, :name  => key_name,
                                            :value => pref,
                                            :type  => :submit)
          end
          html_output << content_tag(:li, item_content, :class => html_class)
        }
      end
    end
  end
end
