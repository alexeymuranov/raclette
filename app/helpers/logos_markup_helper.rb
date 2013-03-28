## encoding: UTF-8

module LogosMarkupHelper
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

  def logo_box_inline_style_for_user(user)
    if user.admin?
      'background-color:Red'
    elsif user.manager?
      'background-color:Blue'
    elsif user.secretary?
      'background-color:Aqua'
    else
      'background-color:Green'
    end
  end

  def path_logo_links_to(user)
    if user.admin?
      admin_tools_overview_path
    elsif user.manager?
      root_path
    elsif user.secretary?
      root_path
    else
      root_path
    end
  end
end
