## encoding: UTF-8

class Admin::SafeUserIPsController < AdminController

  class User < Accessors::User
    has_many :safe_ips, :class_name => :KnownIP,
                        :through    => :safe_user_ips,
                        :source     => :known_ip

    self.all_sorting_columns = [:username,
                                :full_name,
                                :account_deactivated,
                                :admin,
                                :manager,
                                :secretary,
                                :a_person]
    self.default_sorting_column = :username
  end

  class KnownIP < Accessors::KnownIP
    has_many :safe_users, :class_name => :User,
                          :through    => :safe_user_ips,
                          :source     => :user

    self.all_sorting_columns = [:ip, :description]
    self.default_sorting_column = :ip
  end

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
