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

    params[:safe_user_ids_for_known_ips] ||= {}
    
    Admin::KnownIP.all.each do |known_ip|
      known_ip.safe_user_ids =
          params[:safe_user_ids_for_known_ips][known_ip.id.to_s]      
    end

    redirect_to admin_safe_user_ips_path
  end
end
