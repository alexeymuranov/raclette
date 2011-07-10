## encoding: UTF-8

class Admin::AdminToolsController < AdminController

  def overview
    @users = Admin::User.default_order
    @known_ips = Admin::KnownIP.default_order
    
    @title = t('application_layout.navigation_links.admin_tools')
  end
end
