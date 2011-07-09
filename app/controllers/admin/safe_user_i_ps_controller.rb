## encoding: UTF-8

class Admin::SafeUserIPsController < AdminController

  def index
    @users = Admin::User.default_order
    @known_ips = Admin::KnownIP.default_order
    
    @title = t('admin.safe_user_i_ps.index.title')
  end

  def edit_all
    @users = Admin::User.default_order
    @known_ips = Admin::KnownIP.default_order

    @title = t('admin.safe_user_i_ps.edit_all.title')
  end
  
  def update_all

    params[:safe_ip_ids_for_users] ||= {}
    
    Admin::User.all.each do |user|
      user.safe_ip_ids = params[:safe_ip_ids_for_users][user.id.to_s]      
    end

    redirect_to admin_safe_user_ips_path
  end
end
