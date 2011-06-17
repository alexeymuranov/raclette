class Admin::AdminToolsController < AdminController

  def overview
    @users = Admin::User.all
    @known_ips = Admin::KnownIP.all
    
    @title = t("application_layout.navigation_links.admin_tools")
  end
end
