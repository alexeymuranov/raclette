## encoding: UTF-8

class Admin::UsersController < AdminController

  class User < Accessors::User
    init_associations

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
    init_associations

    self.all_sorting_columns = [:ip, :description]
    self.default_sorting_column = :ip
  end

  before_filter :find_user, :only => [:show, :edit, :update, :destroy]

  def index
    case request.format
    when Mime::HTML
      @attributes = [ :username,
                      :full_name,
                      :account_deactivated,
                      :admin,
                      :manager,
                      :secretary,
                      :a_person ]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attributes = [ :username,
                      :full_name,
                      :email,
                      :account_deactivated,
                      :admin,
                      :manager,
                      :secretary,
                      :a_person ]
    end

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

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @users = paginate(@users)

        render :index
      end

      requested_format.xml do
        render :xml  => @users,
               :only => @attributes
      end

      requested_format.js do
        case params[:button]
        when 'show_email_addresses', 'hide_email_addresses'
          render :update_email_list
        end
      end

      requested_format.ms_excel_2003_xml do
        render :collection_ms_excel_2003_xml => @users,
               :only                         => @attributes
      end

      requested_format.csv do
        render :collection_csv => @users,
               :only           => @attributes
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @users,
               :only                             => @attributes
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @users,
               :only               => @attributes
      end
    end
  end

  def show
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

    @safe_ip_attributes = [:ip, :description]

    ip_sort_params = (params[:sort] && params[:sort][:safe_ips]) || {}
    @safe_ips = KnownIP.sort(@user.safe_ips, ip_sort_params)
    @sorting_column = KnownIP.last_sort_column
    @sorting_direction = KnownIP.last_sort_direction

    @known_ips_column_headers = KnownIP.human_column_headers

    @title = t('admin.users.show.title', :username => @user.username)
  end

  def new
    @user = User.new

    render_new_properly
  end

  def edit
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
    @user.destroy
    flash[:notice] = t('flash.admin.users.destroy.success',
                       :username => @user.username)

    redirect_to :action => :index
  end

  private

    def find_user
      @user = User.find(params[:id])
    end

    def render_new_properly
      # NOTE: this seems redundant because coincides with KnownIP.all_sorting_columns
      @known_ip_attributes = [:ip, :description]

      ip_sort_params = (params[:sort] && params[:sort][:safe_ips]) || {}
      @known_ips = KnownIP.sort(KnownIP.scoped, ip_sort_params)
      @safe_ips = nil
      @sorting_column = KnownIP.last_sort_column
      @sorting_direction = KnownIP.last_sort_direction

      @title = t('admin.users.new.title')

      render :new
    end

    def render_edit_properly
      @known_ip_attributes = [:ip, :description]

      ip_sort_params = (params[:sort] && params[:sort][:safe_ips]) || {}
      @known_ips = KnownIP.sort(KnownIP.scoped, ip_sort_params)
      @safe_ips = KnownIP.sort(@user.safe_ips, ip_sort_params)
      @sorting_column = KnownIP.last_sort_column
      @sorting_direction = KnownIP.last_sort_direction

      @title = t('admin.users.edit.title', :username => @user.username)

      render :edit
    end

end
