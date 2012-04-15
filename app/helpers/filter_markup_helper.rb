## encoding: UTF-8

module FilterMarkupHelper

  def filter_by_prefix(str_attr, prefixes, filtering_values, param_key_nesting=nil, html_options={})
    options = { :class => 'filtering_prefixes' }.merge(html_options)
    if filtering_values.key?(str_attr)
      current_prefix = filtering_values[str_attr].sub(/\%+\z/, '').mb_chars.upcase.to_s
      current_prefix = prefixes.find { |pref|
        pref.mb_chars.upcase.to_s == current_prefix
      }
    else
      current_prefix = nil
    end
    content_tag(:nav, options) do
      form_tag(nil, :method => :get ) do
        key_name = "filter[#{str_attr}]"
        saved_params = params.except(key_name).merge( :request_type => 'filter' )
        hidden_field_tags_from_hash(saved_params) <<
          content_tag(:ul) do
            prefixes.inject ''.html_safe do |html_output, pref|
              html_output << content_tag(:li, :class => 'filtering_prefix') {
                pref == current_prefix ?
                        pref :
                        content_tag(:button, pref, :name  => key_name,
                                                   :value => pref,
                                                   :type  => 'submit')
              }
            end
          end
      end
    end
  end
end
