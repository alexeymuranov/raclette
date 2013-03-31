## encoding: UTF-8

class Admin::SafeUserIPsController < AdminController

  def index
    @users = User.default_order
    @known_ips = KnownIP.default_order
  end

  def edit_all
    @users = User.default_order
    @known_ips = KnownIP.default_order
  end

  def update_all
    params[:safe_user_ids_for_known_ips] ||= {}

    KnownIP.all.each do |known_ip|
      new_safe_user_ids = params[:safe_user_ids_for_known_ips][known_ip.to_param]
      known_ip.safe_user_ids = new_safe_user_ids
    end

    redirect_to :action => :index
  end
end
