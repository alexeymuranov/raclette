## encoding: UTF-8

class Admin::UsersController < AdminController
  helper_method :sort_column, :sort_direction

  def index
    @users = Admin::User.order("#{sort_column} #{sort_direction}")

    @title = t('admin.users.index.title')
  end

  def show
    @user = Admin::User.find(params[:id])

    @title = t('admin.users.show.title', :username => @user.username)
  end

  def new
    @user = Admin::User.new
    @known_ips = Admin::KnownIP.all

    @title = t('admin.users.new.title')
  end

  def edit
    @user = Admin::User.find(params[:id])
    @safe_ips = @user.safe_ips
    @other_ips = Admin::KnownIP.all - @safe_ips

    @title = t('admin.users.edit.title', :username => @user.username)
  end

  def create
  
    params[:admin_user][:safe_ip_ids] ||= []

    params[:admin_user].delete(:email)\
        if params[:admin_user][:email].blank?
        
    params[:admin_user].delete(:comments)\
        if params[:admin_user][:comments].blank?

    @user = Admin::User.new(params[:admin_user])

    if @user.save
      flash[:success] = t('admin.users.create.flash.success',
                          :username => @user.username)
      redirect_to @user
    else
      flash[:error] = t('admin.users.create.flash.failure')
      @title = t('admin.users.new.title')
      render 'new'
    end
  end

  def update
    @user = Admin::User.find(params[:id])
    
    params[:admin_user][:safe_ip_ids] ||= []

    params[:admin_user].delete(:email)\
        if params[:admin_user][:email].blank?

    params[:admin_user].delete(:comments)\
        if params[:admin_user][:comments].blank?

    unless params[:change_password]
      params.delete(:current_password)
      params[:admin_user].delete(:new_password)
      params[:admin_user].delete(:new_password_confirmation)
    end

    if @user == current_user
      params[:admin_user].delete(:account_deactivated)
      params[:admin_user].delete(:admin)
    else
      params.delete(:current_password)
      params[:admin_user].delete(:new_password)
      params[:admin_user].delete(:new_password_confirmation)
    end

    current_password = params[:current_password]

    if current_password.nil? || @user.has_password?(current_password)
      if @user.update_attributes(params[:admin_user])
        flash[:notice] = t('admin.users.update.flash.success',
                           :username => @user.username)
        redirect_to @user
      else
        flash.now[:error] = t('admin.users.update.flash.failure')

        @user = Admin::User.find(params[:id])
        @safe_ips = @user.safe_ips
        @other_ips = Admin::KnownIP.all - @safe_ips
        @title =  t('admin.users.edit.title', :username => @user.username)
        render 'edit'
      end
    else
      flash.now[:error] = t('admin.users.update.flash.wrong_password')
      
      @user = Admin::User.find(params[:id])
      @safe_ips = @user.safe_ips
      @other_ips = Admin::KnownIP.all - @safe_ips
      @title = t('admin.users.edit.title', :username => @user.username)
      render 'edit'
    end
  end

  def destroy
    @user = Admin::User.find(params[:id])
    @user.destroy
    flash[:notice] =  t('admin.users.destroy.flash.success', :username => @user.username)

    redirect_to admin_users_url
  end

  private
  
    def sort_column  
      Admin::User.column_names.include?(params[:sort]) ? params[:sort] : 'username'
    end
  
end
