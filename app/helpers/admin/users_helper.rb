module Admin::UsersHelper

  def logo_box_inline_style_for_user(user)
    if user.admin?
      'background-color:Red'
    elsif user.manager?
      'background-color:Blue'
    elsif user.secretary?
      'Aqua'
    else
      'background-color:Green'
    end
  end
  
  def path_logo_links_to(user)
    if user.admin?
      admin_admin_tools_overview_path
    elsif user.manager?
      root_path
    elsif user.secretary?
      root_path
    else
      root_path
    end
  end
end
