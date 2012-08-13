## encoding: UTF-8

class Admin::UsersController < AdminController

  class User < Accessors::User
    has_many :safe_ips, :class_name => :KnownIP,
                        :through    => :safe_user_ips,
                        :source     => :known_ip

    self.all_sorting_columns = [ :username,
                                 :full_name,
                                 :account_deactivated,
                                 :admin,
                                 :manager,
                                 :secretary,
                                 :a_person ]
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
    @query_type = params[:query_type]
    @submit_button = params[:button]

    # FIXME: strange if this is necessary:
    params.except!(:query_type, :commit, :button)

    case request.format
    when Mime::HTML
      @attributes = [ :username,
                      :full_name,
                      :account_deactivated,
                      :admin,
                      :manager,
                      :secretary,
                      :a_person ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML, Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attributes = [ :username,
                      :full_name,
                      :email,
                      :account_deactivated,
                      :admin,
                      :manager,
                      :secretary,
                      :a_person ]
    end

    @column_types = User.column_db_types

    @users = User.scoped

    # Filter:
    @users = User.filter(@users, params[:filter], @attributes)
    @filtering_values = User.last_filter_values
    @filtered_users_count = @users.count

    # Sort:
    User.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:users]) || {}
    @users = User.sort(@users, sort_params)
    @sorting_column = User.last_sort_column
    @sorting_direction = User.last_sort_direction

    # Compose mailing list:
    if params[:list_email_addresses]
      @mailing_list_users = @users.select { |user| !user.email.blank? }
      @mailing_list = @mailing_list_users.collect(&:formatted_email).join(', ')
    end

    unless request.format == Mime::JS
      @column_headers = User.human_column_headers
    end

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @users = paginate(@users)

        # @title = t('admin.users.index.title')  # or: User.model_name.human.pluralize
        render :index
      end

      requested_format.xml do
        render :xml  => @users,
               :only => @attributes
      end

      requested_format.js do
        case @query_type
        when 'show_email_addresses', 'hide_email_addresses'
          render :update_email_list
        end
      end

      requested_format.ms_excel_2003_xml do
        render :collection_ms_excel_2003_xml => @users,
               :only                         => @attributes,
               :headers                      => @column_headers
      end

      requested_format.csv do
        render :collection_csv => @users,
               :only           => @attributes,
               :headers        => @column_headers
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @users,
               :only                             => @attributes,
               :headers                          => @column_headers
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @users,
               :only               => @attributes,
               :headers            => @column_headers
      end
    end
  end

  def show
    @user = User.find(params[:id])

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
    @other_attributes << :last_signed_in_at unless
      @user.last_signed_in_at.blank?

    @safe_ips_attributes = [:ip, :description]

    ip_sort_params = (params[:sort] && params[:sort][:safe_ips]) || {}
    @safe_ips = KnownIP.sort(@user.safe_ips, ip_sort_params)
    @sorting_column = KnownIP.last_sort_column
    @sorting_direction = KnownIP.last_sort_direction

    @column_types = User.column_db_types
    @known_ips_column_types = KnownIP.column_db_types
    @known_ips_column_headers = KnownIP.human_column_headers

    @title = t('admin.users.show.title', :username => @user.username)
  end

  def new
    @user = User.new

    render_new_properly
  end

  def edit
    @user = User.find(params[:id])

    render_edit_properly
  end

  def create

    params[:user][:safe_ip_ids] ||= []

    params[:user][:email] = nil if params[:user][:email].blank?

    params[:user][:comments] = nil if params[:user][:comments].blank?

    @user = User.new(params[:user])

    if @user.save
      flash[:success] = t('flash.admin.users.create.success',
                          :username => @user.username)
      redirect_to :action => :show, :id => @user
    else
      flash.now[:error] = t('flash.admin.users.create.failure')

      render_new_properly  # is it OK?
    end
  end

  def update
    @user = User.find(params[:id])

    params[:user][:safe_ip_ids] ||= []

    params[:user][:email] = nil if params[:user][:email].blank?

    params[:user][:comments] = nil if params[:user][:comments].blank?

    if @user == current_user
      params[:user].except!(:account_deactivated, :admin)
    else
      params.delete(:change_password)
      params[:user].except!(:new_password, :new_password_confirmation)
    end

    unless params[:change_password]
      params.delete(:current_password)
      params[:user].except!(:new_password, :new_password_confirmation)
    end

    current_password = params[:current_password]

    if current_password.nil? || @user.has_password?(current_password)
      if @user.update_attributes(params[:user])
        flash[:notice] = t('flash.admin.users.update.success',
                           :username => @user.username )
        redirect_to :action => :show, :id => @user
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
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = t('flash.admin.users.destroy.success',
                       :username => @user.username)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @column_types = User.column_db_types
      # NOTE: this seems redundant because coincides with KnownIP.all_sorting_columns
      @known_ips_attributes = [:ip, :description]
      @known_ips_column_types = KnownIP.column_db_types
      @known_ips_column_headers = KnownIP.human_column_headers

      @safe_ips = nil
      ip_sort_params = (params[:sort] && params[:sort][:safe_ips]) || {}
      @other_ips = KnownIP.sort(KnownIP.scoped, ip_sort_params)
      @sorting_column = KnownIP.last_sort_column
      @sorting_direction = KnownIP.last_sort_direction

      @title = t('admin.users.new.title')

      render :new
    end

    def render_edit_properly
      @column_types = User.column_db_types
      @known_ips_attributes = [:ip, :description]
      @known_ips_column_types = KnownIP.column_db_types
      @known_ips_column_headers = KnownIP.human_column_headers

      ip_sort_params = (params[:sort] && params[:sort][:safe_ips]) || {}
      @safe_ips = KnownIP.sort(@user.safe_ips, ip_sort_params)
      @other_ips = KnownIP.sort(KnownIP.scoped, ip_sort_params) -
        @safe_ips
      @sorting_column = KnownIP.last_sort_column
      @sorting_direction = KnownIP.last_sort_direction

      @title = t('admin.users.edit.title', :username => @user.username)

      render :edit
    end

end
