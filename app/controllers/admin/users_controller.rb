## encoding: UTF-8

# require 'admin/known_i_p'  # To solve a problem with autoloading
# require 'admin/safe_user_i_p'  # To solve a problem with autoloading

class Admin::UsersController < AdminController

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.except!(:query_type, :commit, :button)

    if @query_type == 'filter' && @submit_button == 'clear_button'
      params.delete(:filter)
    end

    @attributes = [ :username,
                    :full_name,
                    :account_deactivated,
                    :admin,
                    :manager,
                    :secretary,
                    :a_person ]

    set_column_types

    # Filter:
    @all_filtered_users = filter(Admin::User.scoped)

    # Sort:
    @all_filtered_users = sort(@all_filtered_users, :users)  # html_table_id = :users

    # Paginate:
    @users = paginate(@all_filtered_users)

    # Compose mailing list:
    if params[:list_email_addresses]
      @mailing_list_users =
          @all_filtered_users.select { |user| !user.email.blank? }
      @mailing_list = @mailing_list_users.collect(&:formatted_email).join(', ')
    end

    @attributes_for_download = [ :username,
                                 :full_name,
                                 :email,
                                 :account_deactivated,
                                 :admin,
                                 :manager,
                                 :secretary,
                                 :a_person ]

    set_column_headers
    set_column_headers_for_download

    respond_to do |requested_format|
      requested_format.html do
        # @title = t('admin.users.index.title')  # or: Admin::User.model_name.human.pluralize
        render :index
      end

      requested_format.xml do
        render :xml  => @all_filtered_users,
               :only => @attributes_for_download
      end

      requested_format.js do
        case @query_type
        when 'show_email_addresses', 'hide_email_addresses'
          render :update_email_list
        end
      end

      requested_format.ms_excel_2003_xml do
        render_ms_excel_2003_xml_for_download\
            @all_filtered_users,
            @attributes_for_download,
            @column_headers_for_download,
            "#{Admin::User.model_name.human.pluralize}"\
            " #{Time.now.in_time_zone.strftime('%Y-%m-%d %k_%M')}"\
            ".excel2003.xml"  # defined in ApplicationController
      end

      requested_format.csv do
        render_csv_for_download\
            @all_filtered_users,
            @attributes_for_download,
            @column_headers_for_download,
            "#{Admin::User.model_name.human.pluralize}"\
            " #{Time.now.in_time_zone.strftime('%Y-%m-%d %k_%M')}"\
            ".csv"  # defined in ApplicationController
      end
    end
  end

  def show
    @user = Admin::User.find(params[:id])
    @safe_ips = @user.safe_ips.order(sort_sql(:safe_ips))

    @main_attributes = [ :username,
                         :full_name,
                         :email,
                         :account_deactivated,
                         :admin,
                         :manager,
                         :secretary,
                         :a_person ]
    @main_attributes << :person_id if @user.a_person?
    @main_attributes << :comments

    @other_attributes = []
    @other_attributes << :last_signed_in_at\
        unless @user.last_signed_in_at.blank?

    @safe_ips_attributes = [ :ip, :description ]

    set_column_types
    set_column_headers
    set_known_ips_column_types
    set_known_ips_column_headers

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

    @acceptable_attributes = [ 'username', 'full_name', 'email',
        'account_deactivated', 'admin', 'manager', 'secretary', 'a_person',
        'comments',
        'password', 'password_confirmation',
        'safe_ip_ids' ]

    params[:admin_user].slice!(*@acceptable_attributes)

    @user = Admin::User.new(params[:admin_user], :as => :admin)

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

    @acceptable_attributes = [ 'username', 'full_name', 'email',
        'account_deactivated', 'admin', 'manager', 'secretary', 'a_person',
        'comments',
        'current_password', 'new_password', 'new_password_confirmation',
        'safe_ip_ids' ]

    params[:admin_user].slice!(*@acceptable_attributes)

    current_password = params[:current_password]

    if current_password.nil? || @user.has_password?(current_password)
      if @user.update_attributes(params[:admin_user], :as => :admin)
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

    def render_new_properly
      set_column_types
      set_column_headers
      @known_ips_attributes = [ :ip, :description ]
      set_known_ips_column_types
      set_known_ips_column_headers

      @safe_ips = nil
      @other_ips = Admin::KnownIP.order(sort_sql(:safe_ips))

      @title = t('admin.users.new.title')

      render :new
    end

    def render_edit_properly
      set_column_types
      set_column_headers
      @known_ips_attributes = [ :ip, :description ]
      set_known_ips_column_types
      set_known_ips_column_headers

      @safe_ips = @user.safe_ips.order(sort_sql(:safe_ips))
      @other_ips = Admin::KnownIP.order(sort_sql(:safe_ips)) - @safe_ips

      @title = t('admin.users.edit.title', :username => @user.username)

      render :edit
    end

    def html_table_id_to_class(html_table_id)
      case html_table_id
      when :users then Admin::User
      when :safe_ips then Admin::KnownIP
      else nil
      end
    end

    def default_sort_column(html_table_id)
      case html_table_id
      when :users then :username
      when :safe_ips then :ip
      else nil
      end
    end

    def set_column_types
      @column_types = {}
      Admin::User.columns_hash.each do |key, value|
        @column_types[key.to_sym] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = Admin::User.human_attribute_name(attr)

        case type
        when :boolean
          @column_headers[attr] = I18n.t('formats.attribute_name?',
                                         :attribute => human_name)
        else
          @column_headers[attr] = I18n.t('formats.attribute_name:',
                                         :attribute => human_name)
        end
      end
    end

    def set_column_headers_for_download
      @column_headers_for_download = {}
      @column_types.each do |attr, type|
        @column_headers_for_download[attr] =
            Admin::User.human_attribute_name(attr)
      end
    end

    def set_known_ips_column_types
      @known_ips_column_types = {}
      Admin::KnownIP.columns_hash.each do |key, value|
        @known_ips_column_types[key.to_sym] = value.type
      end
    end

    def set_known_ips_column_headers
      @known_ips_column_headers = {}
      @known_ips_column_types.each do |attr, type|
        human_name = Admin::KnownIP.human_attribute_name(attr)

        case type
        when :boolean
          @known_ips_column_headers[attr] = I18n.t('formats.attribute_name?',
                                                   :attribute => human_name)
        else
          @known_ips_column_headers[attr] = I18n.t('formats.attribute_name:',
                                                   :attribute => human_name)
        end
      end
    end

end
