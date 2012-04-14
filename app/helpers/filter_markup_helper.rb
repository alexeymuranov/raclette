## encoding: UTF-8

module FilterMarkupHelper  # WIP
  def filter_by_prefix(str_attr, prefixes, filtering_values, param_key_nesting=nil, html_options={})  # TODO
    options = { :class => 'filtering_prefixes' }.merge(html_options)
    # klass = models.klass
    if filtering_values.key?(str_attr)
      current_prefix = filtering_values[str_attr].sub(/\%+\z/, '').mb_chars.upcase.to_s
      current_prefix = prefixes.find { |pref|
        pref.mb_chars.upcase.to_s == current_prefix
      }
    else
      current_prefix = nil
    end
    content_tag(:nav, options) do
      content_tag :ul do
        html_output = ''.html_safe
        prefixes.each do |pref|
          html_output << content_tag(:li, :class => 'filtering_prefix') do
            if pref == current_prefix
              pref
            else
              new_params = params.deep_merge( :filter => { str_attr => pref } )
              link_to(pref, new_params)
            end
          end
        end
        html_output.html_safe
      end
    end
  end
end
