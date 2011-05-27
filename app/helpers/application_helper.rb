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

  def show_icon(size=1)
    image_tag SHOW_ICON_FILE_NAMES[size], :alt => 'show'
  end

  EDIT_ICON_FILE_NAMES = [ 'icons/edit-16.png',
                           'icons/edit-24.png',
                           'icons/edit-32.png' ]

  def edit_icon(size=1)
    image_tag EDIT_ICON_FILE_NAMES[size], :alt => 'edit'
  end

  ADD_ICON_FILE_NAMES = [ 'icons/add-16.png',
                          'icons/add-24.png',
                          'icons/add-32.png' ]

  def add_icon(size=1)
    image_tag ADD_ICON_FILE_NAMES[size], :alt => 'add'
  end

  SAVE_ICON_FILE_NAMES = [ 'icons/save-16.png',
                           'icons/save-24.png',
                           'icons/save-32.png' ]

  def save_icon(size=1)
    image_tag SAVE_ICON_FILE_NAMES[size], :alt => 'save'
  end

  DELETE_ICON_FILE_NAMES = [ 'icons/delete-16.png',
                             'icons/delete-24.png',
                             'icons/delete-32.png' ]

  def delete_icon(size=1)
    image_tag DELETE_ICON_FILE_NAMES[size], :alt => 'delete'
  end

  LIST_ALL_ICON_FILE_NAMES = [ 'icons/list_all-16.png',
                               'icons/list_all-24.png',
                               'icons/list_all-32.png' ]

  def list_all_icon(size=1)
    image_tag LIST_ALL_ICON_FILE_NAMES[size], :alt => 'list all'
  end

  YES_ICON_FILE_NAMES = [ 'icons/yes-16.png',
                          'icons/yes-24.png',
                          'icons/yes-32.png' ]

  def yes_icon(size=1)
    image_tag YES_ICON_FILE_NAMES[size], :alt => 'yes', :title => t(:yes)
  end
end
