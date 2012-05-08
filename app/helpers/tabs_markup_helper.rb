## encoding: UTF-8

module TabsMarkupHelper

  def tabs(all_tabs, current_tab, param_key_nesting = nil, html_options = {})
    options = { :class => 'tabs' }.merge(html_options)
    content_tag(:nav, options) do
      form_tag(nil, :method => :get) do
        saved_params =
          params.except(:tab).merge(:request_type => 'activate_tab')
        hidden_fields_from_nested_hash(saved_params) <<
          content_tag(:ul) do
            all_tabs.inject(''.html_safe) do |html_output, tab|
              tab_title = t(:title, :scope => [controller_name, tab])
              if tab == current_tab
                html_output <<
                content_tag(:li, :class => 'tab enabled active') {
                  content_tag(:span, tab_title, :class => 'tab')
                }
              else
                html_output <<
                  content_tag(:li, :class => 'tab enabled inactive') {
                    button_tag(tab_title, :name  => 'tab',
                                          :value => tab,
                                          :type  => 'submit',
                                          :class => 'tab')
                  }
              end
            end
          end
      end
    end
  end
end
