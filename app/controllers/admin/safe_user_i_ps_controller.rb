## encoding: UTF-8

class Admin::SafeUserIPsController < AdminController

  class User < self::User
    self.all_sorting_columns = [:username,
                                :full_name,
                                :account_deactivated,
                                :admin,
                                :manager,
                                :secretary,
                                :a_person]
    self.default_sorting_column = :username
  end

  class KnownIP < self::KnownIP
    self.all_sorting_columns = [:ip, :description]
    self.default_sorting_column = :ip
  end

  param_accessible(Set['safe_user_ids_for_known_ips'], :only => :update_all)

  def index
    @users = User.default_order
    @known_ips = KnownIP.default_order

    # @title = t('admin.safe_user_i_ps.index.title')
  end

  def edit_all
    @users = User.default_order
    @known_ips = KnownIP.default_order

    # @title = t('admin.safe_user_i_ps.edit_all.title')
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
