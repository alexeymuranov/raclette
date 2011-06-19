module Admin::UsersHelper

  def user_permissions_color_code(user)
    if user.admin?
      '#f00'
    elsif user.manager?
      '#00f'
    elsif user.secretary?
      '#0ff'
    else
      '#0f0'
    end
  end
  
  def logo_links_to_path(user)
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
