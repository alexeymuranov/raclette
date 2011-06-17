## encoding: UTF-8

class Admin::SafeUserIPsController < AdminController

  def index
    @users = Admin::User.all
    @known_ips = Admin::KnownIP.all
    
    @title = t('admin.safe_user_i_ps.index.title')
  end

  def edit_all
    @users = Admin::User.all
    @known_ips = Admin::KnownIP.all

    @title = t('admin.safe_user_i_ps.edit_all.title')
  end
  
  def update_all # FIXME
    @users = Admin::User.all
    @known_ips = Admin::KnownIP.all

    if params[:known_ip_is_safe_for_user].nil?
      Admin::SafeUserIP.delete_all
    else
      Admin::KnownIP.all.each do |known_ip|
        user_is_safe = params[:known_ip_is_safe_for_user][known_ip.id.to_s]
        if user_is_safe.nil? # if none is safe
          known_ip.safe_users.delete_all
        else
          Admin::User.all.each do |user|
            if user_is_safe[user.id.to_s] # if safe
              known_ip.safe_users << user unless known_ip.safe_users.include?(user)
            else
              known_ip.safe_users.delete(user)
            end
          end
        end
      end
    end

    redirect_to admin_safe_user_ips_path
  end
end
