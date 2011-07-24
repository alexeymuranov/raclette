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

  def rails_logo
    image_tag 'logos/rails-logo.png', :alt => 'Ruby on Rails'
  end

  def ruby_logo
    image_tag 'logos/ruby-logo.png', :alt => 'Ruby'
  end

  SHOW_ICON_FILE_NAMES = [ 'icons/show-16.png',
                           'icons/show-24.png',
                           'icons/show-32.png' ]

  def show_pictogram(size=1)
    # image_tag SHOW_ICON_FILE_NAMES[size], :alt => 'show'
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '⇒', :class => 'pictogram',
                            :style => css_style
  end

  EDIT_ICON_FILE_NAMES = [ 'icons/edit-16.png',
                           'icons/edit-24.png',
                           'icons/edit-32.png' ]

  def edit_pictogram(size=1)
    # image_tag EDIT_ICON_FILE_NAMES[size], :alt => 'edit'
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '✎', :class => 'pictogram',
                            :style => css_style
  end

  ADD_ICON_FILE_NAMES = [ 'icons/add-16.png',
                          'icons/add-24.png',
                          'icons/add-32.png' ]

  def add_pictogram(size=1)
    # image_tag ADD_ICON_FILE_NAMES[size], :alt => 'add'
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '＋', :class => 'pictogram',
                            :style => css_style
  end

  DELETE_ICON_FILE_NAMES = [ 'icons/delete-16.png',
                             'icons/delete-24.png',
                             'icons/delete-32.png' ]

  def delete_pictogram(size=1)
    # image_tag DELETE_ICON_FILE_NAMES[size], :alt => 'delete'
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '✕', :class => 'pictogram',
                            :style => css_style
  end

  LIST_ALL_ICON_FILE_NAMES = [ 'icons/list_all-16.png',
                               'icons/list_all-24.png',
                               'icons/list_all-32.png' ]

  def list_all_pictogram(size=1)
    # image_tag LIST_ALL_ICON_FILE_NAMES[size], :alt => 'list all'
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '⇕', :class => 'pictogram',
                            :style => css_style
  end

  YES_ICON_FILE_NAMES = [ 'icons/yes-16.png',
                          'icons/yes-24.png',
                          'icons/yes-32.png' ]

  def yes_pictogram(size=1)
    # image_tag YES_ICON_FILE_NAMES[size], :alt => t(:yes), :title => t(:yes)
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
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

  def sortable(table_name, column, title = nil, html_options = {})
    title ||= column.to_s.titleize

    if column.intern == sort_column(table_name)  # column is current sort column
      if sort_direction(table_name) == :asc  # current sort direction is asc
        sort_indicator = '▲ '
        direction_on_click = :desc
        css_class = "current asc"
      else
        sort_indicator = '▼ '
        direction_on_click = :asc
        css_class = "current desc"
      end
    else
      sort_indicator = ''
      direction_on_click = :asc
      css_class = nil
    end

    options = params.deep_merge :page => 1,
                                :sort => { table_name =>
                                           { :column    => column,
                                             :direction => direction_on_click } },
                                :anchor => table_name,
                                :query_type => 'sort'

    if html_options[:class].blank?
      html_options[:class] = css_class
    else
      html_options[:class] += " #{css_class}"
    end

    link_to sort_indicator+title, options, html_options
  end
end
