## encoding: UTF-8

class Admin::UsersController < AdminController

  def index
    @query_type = params[:query_type]
    params.delete(:query_type)
    # params.delete(:commit)
    # params.delete(:button)

    @attributes = [ :username,
                    :full_name,
                    :account_deactivated,
                    :admin,
                    :manager,
                    :secretary,
                    :a_person ]

    @column_types = {}
    @attributes.each do |attr|
      @column_types[attr] = Admin::User.columns_hash[attr.to_s].type
    end

    # Filter:
    @all_filtered_users = filter(Admin::User.scoped)

    # Sort:
    @all_filtered_users = sort(@all_filtered_users, :users)  # table_name = :users

    # Paginate:
    @users = paginate(@all_filtered_users)

    # Compose mailing list:
    if params[:list_email_addresses]
      @mailing_list_users =
          @all_filtered_users.select { |user| !user.email.blank? }
      @mailing_list = @mailing_list_users.collect(&:formatted_email).join(', ')
    end

    # @title = t('admin.users.index.title')  # or: Admin::User.human_name.pluralize

    @attributes_for_download = [ :username,
                                 :full_name,
                                 :email,
                                 :account_deactivated,
                                 :admin,
                                 :manager,
                                 :secretary,
                                 :a_person ]

    @column_types = {}
    @attributes_for_download.each do |attr|
      @column_types[attr] =
          Admin::User.columns_hash[attr.to_s].type
    end

    respond_to do |requested_format|
      requested_format.html do
        render :index
      end

      requested_format.xml do
        render :xml  => @all_filtered_users,
               :only => @attributes_for_download
      end

      requested_format.js do
        case @query_type
        # when 'filter', 'sort'
        # when 'repaginate'
        when 'show_email_addresses', 'hide_email_addresses'
          render :update_email_list
        # else
        end
      end

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download\
            Admin::User, @all_filtered_users,
            @attributes_for_download, @column_types  # defined in ApplicationController
      end

      requested_format.csv do
        render_csv_for_download\
            Admin::User, @all_filtered_users,
            @attributes_for_download  # defined in ApplicationController
      end
    end
  end

  def show
    @user = Admin::User.find(params[:id])
    @safe_ips = @user.safe_ips.order(sort_sql(:safe_ips))

    @key_attributes = [ :username ]
    @other_main_attributes = [ :full_name,
                               :email,
                               :account_deactivated,
                               :admin,
                               :manager,
                               :secretary,
                               :a_person ]
    @other_main_attributes << :person_id if @user.a_person?
    @other_main_attributes << :comments
    @other_attributes = []
    @other_attributes << :last_signed_in_at\
        unless @user.last_signed_in_at.blank?

    @safe_ips_attributes = [ :ip, :description ]
    @safe_ips_column_types = {}
    @safe_ips_attributes.each do |attr|
      @safe_ips_column_types[attr] =
          Admin::KnownIP.columns_hash[attr.to_s].type
    end

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

    @acceptable_attributs = [ 'username', 'full_name', 'email',
        'account_deactivated', 'admin', 'manager', 'secretary', 'a_person',
        'comments',
        'password', 'password_confirmation',
        'safe_ip_ids' ]

    params[:admin_user].slice!(*@acceptable_attributs)

    @user = Admin::User.new(params[:admin_user])

    if @user.save
      flash[:success] = t('flash.admin.users.create.success',
                          :username => @user.username)
      redirect_to @user
    else
      flash.now[:error] = t('flash.admin.users.create.failure')

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

    if @user == current_user
      params[:admin_user].except!(:account_deactivated, :admin)
    else
      params.delete(:change_password)
      params[:admin_user].except!(:new_password, :new_password_confirmation)
    end

    unless params[:change_password]
      params.delete(:current_password)
      params[:admin_user].except!(:new_password, :new_password_confirmation)
    end

    @acceptable_attributs = [ 'username', 'full_name', 'email',
        'account_deactivated', 'admin', 'manager', 'secretary', 'a_person',
        'comments',
        'current_password', 'new_password', 'new_password_confirmation',
        'safe_ip_ids' ]

    params[:admin_user].slice!(*@acceptable_attributs)

    current_password = params[:current_password]

    if current_password.nil? || @user.has_password?(current_password)
      if @user.update_attributes(params[:admin_user])
        flash[:notice] = t('flash.admin.users.update.success',
                           :username => @user.username)
        redirect_to @user
      else
        flash.now[:error] = t('flash.admin.users.update.failure')

        render_edit_properly  # is it OK?
      end
    else
      flash.now[:error] = t('flash.admin.users.update.wrong_password')

      render_edit_properly  # is it OK?
    end
  end

  def destroy
    @user = Admin::User.find(params[:id])
    @user.destroy
    flash[:notice] = t('flash.admin.users.destroy.success',
                       :username => @user.username)

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
      @known_ips_attributes = [ :ip, :description ]
      @known_ips_column_types = {}
      @known_ips_attributes.each do |attr|
        @known_ips_column_types[attr] =
            Admin::KnownIP.columns_hash[attr.to_s].type
      end

      @safe_ips = nil
      @other_ips = Admin::KnownIP.order(sort_sql(:safe_ips))

      @title = t('admin.users.new.title')

      render :new
    end

    def render_edit_properly
      @known_ips_attributes = [ :ip, :description ]
      @known_ips_column_types = {}
      @known_ips_attributes.each do |attr|
        @known_ips_column_types[attr] =
            Admin::KnownIP.columns_hash[attr.to_s].type
      end

      @safe_ips = @user.safe_ips.order(sort_sql(:safe_ips))
      @other_ips = Admin::KnownIP.order(sort_sql(:safe_ips)) - @safe_ips

      @title =  t('admin.users.edit.title', :username => @user.username)

      render :edit
    end

end
