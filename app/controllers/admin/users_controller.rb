## encoding: UTF-8

class Admin::UsersController < AdminController
  helper_method :sort_column, :sort_direction

  def index
    @users = Admin::User.order("#{sort_column(:users)} #{sort_direction(:users)}")

    @displayed_columns = [ :username,
                           :full_name,
                           :account_deactivated,
                           :admin,
                           :manager,
                           :secretary,
                           :a_person ]

    @title = t('admin.users.index.title')  # or: Admin::User.human_name.pluralize
  end

  def show
    @user = Admin::User.find(params[:id])
    @safe_ips = @user.safe_ips.order("#{sort_column(:safe_ips)} #{sort_direction(:safe_ips)}")

    @key_displayed_columns = [ :username ]
    @main_displayed_columns = [ :full_name,
                                :email,
                                :account_deactivated,
                                :admin,
                                :manager,
                                :secretary,
                                :a_person ]
    if @user.a_person? then @main_displayed_columns << :person_id end
    @main_displayed_columns << :comments
    @other_displayed_columns = [ :last_signed_in_at ]

    @safe_ips_displayed_columns = [ :ip, :description ]

    @title = t('admin.users.show.title', :username => @user.username)
  end

  def new
    @user = Admin::User.new

    render_new_properly
  end

  def edit
    @user = Admin::User.find(params[:id])

    render_edit_properly
  end

  def create

    params[:admin_user][:safe_ip_ids] ||= []

    params[:admin_user].delete(:email)\
        if params[:admin_user][:email].blank?

    params[:admin_user].delete(:comments)\
        if params[:admin_user][:comments].blank?

    @acceptable_attribute_names = [ 'username', 'full_name', 'email',
        'account_deactivated', 'admin', 'manager', 'secretary', 'a_person',
        'comments',
        'password', 'password_confirmation',
        'safe_ip_ids' ]

    params[:admin_user].keep_if do |key, value|
      @acceptable_attribute_names.include? key
    end

    @user = Admin::User.new(params[:admin_user])

    if @user.save
      flash[:success] = t('admin.users.create.flash.success',
                          :username => @user.username)
      redirect_to @user
    else
      flash.now[:error] = t('admin.users.create.flash.failure')

      render_new_properly  # is it OK?
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

    @acceptable_attribute_names = [ 'username', 'full_name', 'email',
        'account_deactivated', 'admin', 'manager', 'secretary', 'a_person',
        'comments',
        'current_password', 'new_password', 'new_password_confirmation',
        'safe_ip_ids' ]

    params[:admin_user].keep_if do |key, value|
      @acceptable_attribute_names.include? key
    end

    current_password = params[:current_password]

    if current_password.nil? || @user.has_password?(current_password)
      if @user.update_attributes(params[:admin_user])
        flash[:notice] = t('admin.users.update.flash.success',
                           :username => @user.username)
        redirect_to @user
      else
        flash.now[:error] = t('admin.users.update.flash.failure')

        render_edit_properly  # is it OK?
      end
    else
      flash.now[:error] = t('admin.users.update.flash.wrong_password')

      render_edit_properly  # is it OK?
    end
  end

  def destroy
    @user = Admin::User.find(params[:id])
    @user.destroy
    flash[:notice] =  t('admin.users.destroy.flash.success', :username => @user.username)

    redirect_to admin_users_url
  end

  private

    def table_name_to_class(table_name)
      case table_name
      when :users then Admin::User
      when :safe_ips then Admin::KnownIP
      else nil
      end
    end

    def default_sort_column(table_name)
      case table_name
      when :users then :username
      when :safe_ips then :ip
      else nil
      end
    end

    def render_new_properly
      @known_ips = Admin::KnownIP.order("#{sort_column(:safe_ips)} #{sort_direction(:safe_ips)}")
      @title = t('admin.users.new.title')

      render :new
    end

    def render_edit_properly
      safe_ips = @user.safe_ips.order("#{sort_column(:safe_ips)} #{sort_direction(:safe_ips)}")
      other_ips = Admin::KnownIP.order("#{sort_column(:safe_ips)} #{sort_direction(:safe_ips)}") - safe_ips
      @known_ips = safe_ips + other_ips  # a strange way to sort 'safe' before 'other'

      @title =  t('admin.users.edit.title', :username => @user.username)

      render :edit
    end

end
