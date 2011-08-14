## encoding: UTF-8

module PictogramsMarkupHelper
#   SHOW_ICON_FILE_NAMES = [ 'icons/show-16.png',
#                            'icons/show-24.png',
#                            'icons/show-32.png' ]

  def show_pictogram(size=1)
    # image_tag SHOW_ICON_FILE_NAMES[size], :alt => 'show'
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '⇒', :class => 'pictogram',
                            :style => css_style
  end

#   EDIT_ICON_FILE_NAMES = [ 'icons/edit-16.png',
#                            'icons/edit-24.png',
#                            'icons/edit-32.png' ]

  def edit_pictogram(size=1)
    # image_tag EDIT_ICON_FILE_NAMES[size], :alt => 'edit'
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '✎', :class => 'pictogram',
                            :style => css_style
  end

#   ADD_ICON_FILE_NAMES = [ 'icons/add-16.png',
#                           'icons/add-24.png',
#                           'icons/add-32.png' ]

  def add_pictogram(size=1)
    # image_tag ADD_ICON_FILE_NAMES[size], :alt => 'add'
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '＋', :class => 'pictogram',
                            :style => css_style
  end

#   DELETE_ICON_FILE_NAMES = [ 'icons/delete-16.png',
#                              'icons/delete-24.png',
#                              'icons/delete-32.png' ]

  def delete_pictogram(size=1)
    # image_tag DELETE_ICON_FILE_NAMES[size], :alt => 'delete'
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '✕', :class => 'pictogram',
                            :style => css_style
  end

#   LIST_ALL_ICON_FILE_NAMES = [ 'icons/list_all-16.png',
#                                'icons/list_all-24.png',
#                                'icons/list_all-32.png' ]

  def list_all_pictogram(size=1)
    # image_tag LIST_ALL_ICON_FILE_NAMES[size], :alt => 'list all'
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '⇕', :class => 'pictogram',
                            :style => css_style
  end

#   YES_ICON_FILE_NAMES = [ 'icons/yes-16.png',
#                           'icons/yes-24.png',
#                           'icons/yes-32.png' ]

  def yes_pictogram(size=1)
    # image_tag YES_ICON_FILE_NAMES[size], :alt => t(:yes), :title => t(:yes)
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '✓', :title => t(:yes),
                            :class => 'pictogram',
                            :style => css_style
  end

  def select_pictogram(size=1)
    css_style = (size == 1) ? '' : "font-size:#{(100*size).to_i}%;"
    content_tag :span, '→', :class => 'pictogram',
                            :style => css_style
  end
end
