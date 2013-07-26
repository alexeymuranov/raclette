## encoding: UTF-8

class Admin::AdminToolsController < Admin::AdminController

  def overview
    @users = Admin::User.default_order
    @known_ips = Admin::KnownIP.default_order
  end
end
