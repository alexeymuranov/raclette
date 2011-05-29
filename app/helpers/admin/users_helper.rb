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
end
