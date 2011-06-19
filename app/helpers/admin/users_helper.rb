module Admin::UsersHelper

  def color_for_user_permissions(user)
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
