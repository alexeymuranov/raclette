## encoding: UTF-8

# require 'admin/known_i_p'      # To solve a problem with autoloading
# require 'admin/safe_user_i_p'  # To solve a problem with autoloading

class Admin::AdminToolsController < AdminController

  def overview
    @users = Admin::User.default_order
    @known_ips = Admin::KnownIP.default_order

    # @title = t('admin.admin_tools.overview.title')
  end
end
