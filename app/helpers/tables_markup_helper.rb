## encoding: UTF-8

module TablesMarkupHelper

  def sortable(html_table_id, column, title = nil, html_options = {})
    title ||= column.to_s.titleize

    if column.intern == sort_column(html_table_id)  # is column the current sort column?
      if sort_direction(html_table_id) == :asc  # is the current sort direction asc?
        sort_indicator = '▲ '
        direction_on_click = :desc
        css_class = 'sort current asc'
      else
        sort_indicator = '▼ '
        direction_on_click = :asc
        css_class = 'sort current desc'
      end
    else
      sort_indicator = ''
      direction_on_click = :asc
      css_class = 'sort'
    end

    options = params.deep_merge :page       => 1,
                                :sort       =>
                                    { html_table_id =>
                                        { :column    => column,
                                          :direction => direction_on_click } },
                                :anchor     => html_table_id,
                                :query_type => 'sort'

    if html_options[:class].blank?
      html_options[:class] = css_class
    else
      html_options[:class] << " #{css_class}"
    end

    link_to sort_indicator + title, options, html_options
  end
end
