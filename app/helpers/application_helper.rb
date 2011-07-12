## encoding: UTF-8

module ApplicationHelper

  def title
    base_title = 'Raclette'
    @title.nil? ? base_title : "#{base_title} | #{@title}"
  end

  LOGO_PICTURE_FILE_NAMES = [ 'logos/raclette-w65.png',
                              'logos/raclette-w130.png',
                              'logos/raclette-w260.png' ]

  def logo(size=1)
    image_tag LOGO_PICTURE_FILE_NAMES[size], :alt => 'raclette'
  end

  SHOW_ICON_FILE_NAMES = [ 'icons/show-16.png',
                           'icons/show-24.png',
                           'icons/show-32.png' ]

  def show_pictogram(size=1)
    # image_tag SHOW_ICON_FILE_NAMES[size], :alt => 'show'
    css_style = "font-size:#{16+8*size}px;"
    content_tag :span, '⇒', :class => 'pictogram',
                            :style => css_style
  end

  EDIT_ICON_FILE_NAMES = [ 'icons/edit-16.png',
                           'icons/edit-24.png',
                           'icons/edit-32.png' ]

  def edit_pictogram(size=1)
    # image_tag EDIT_ICON_FILE_NAMES[size], :alt => 'edit'
    css_style = "font-size:#{16+8*size}px;"
    content_tag :span, '✎', :class => 'pictogram',
                            :style => css_style
  end

  ADD_ICON_FILE_NAMES = [ 'icons/add-16.png',
                          'icons/add-24.png',
                          'icons/add-32.png' ]

  def add_pictogram(size=1)
    # image_tag ADD_ICON_FILE_NAMES[size], :alt => 'add'
    css_style = "font-size:#{16+8*size}px;"
    content_tag :span, '＋', :class => 'pictogram',
                            :style => css_style
  end

  DELETE_ICON_FILE_NAMES = [ 'icons/delete-16.png',
                             'icons/delete-24.png',
                             'icons/delete-32.png' ]

  def delete_pictogram(size=1)
    # image_tag DELETE_ICON_FILE_NAMES[size], :alt => 'delete'
    css_style = "font-size:#{16+8*size}px;"
    content_tag :span, '✕', :class => 'pictogram',
                            :style => css_style
  end

  LIST_ALL_ICON_FILE_NAMES = [ 'icons/list_all-16.png',
                               'icons/list_all-24.png',
                               'icons/list_all-32.png' ]

  def list_all_pictogram(size=1)
    # image_tag LIST_ALL_ICON_FILE_NAMES[size], :alt => 'list all'
    css_style = "font-size:#{16+8*size}px;"
    content_tag :span, '⇕', :class => 'pictogram',
                            :style => css_style
  end

  YES_ICON_FILE_NAMES = [ 'icons/yes-16.png',
                          'icons/yes-24.png',
                          'icons/yes-32.png' ]

  def yes_pictogram(size=1)
    # image_tag YES_ICON_FILE_NAMES[size], :alt => t(:yes), :title => t(:yes)
    css_style = "font-size:#{16+8*size}px;"
    content_tag :span, '✓', :title => t(:yes),
                            :class => 'pictogram',
                            :style => css_style
  end

  def boolean_to_yes_no(bool)
    bool ? t(:yes) : t(:no)
  end

  def boolean_to_picto(bool, size=1)
    bool ? yes_pictogram(size) : t(:no)
  end

  def table_name_to_sort_column_key(table_name)
    (table_name.to_s+'_sort_column').intern
  end

  def table_name_to_sort_direction_key(table_name)
    (table_name.to_s+'_sort_direction').intern
  end

  def sortable(table_id, column, title = nil)
    title ||= column.to_s.titleize

    sort_column_key = table_name_to_sort_column_key(table_id)
    sort_direction_key = table_name_to_sort_direction_key(table_id)

    column_is_current_sort_column = (column.intern == sort_column(table_id))
    current_sort_direction = sort_direction(table_id)
    current_sort_direction_is_asc = (current_sort_direction == :asc)

    css_class = column_is_current_sort_column ? "current #{current_sort_direction.to_s}" : nil
    sort_indicator = column_is_current_sort_column ?
                     (current_sort_direction_is_asc ? '▲ ' : '▼ ') : ''
    direction_on_click = (column_is_current_sort_column && current_sort_direction_is_asc) ? :desc : :asc
    link_to sort_indicator+title, { sort_column_key => column, sort_direction_key => direction_on_click, :anchor => table_id },
                                  { :class => css_class }
  end
end
