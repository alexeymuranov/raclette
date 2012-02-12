## encoding: UTF-8

class Admin::UsersController < AdminController

  class UserResource < self::UserResource
    self.all_sorting_columns = [:username,
                                :full_name,
                                :account_deactivated,
                                :admin,
                                :manager,
                                :secretary,
                                :a_person]
    self.default_sorting_column = :username

    # has_many :safe_ips, :class_name => :KnownIPResource,
    #                     :through    => :safe_user_ips,
    #                     :source     => :known_ip
  end

  class KnownIPResource < self::KnownIPResource
    self.all_sorting_columns = [:ip, :description]
    self.default_sorting_column = :ip
  end

  param_accessible({ 'user' => Set[
                       'username', 'full_name', 'email',
                       'account_deactivated',
                       'admin', 'manager', 'secretary', 'a_person',
                       'comments', 'safe_ip_ids'] },
                     :only => [:create, :update] )
  param_accessible({ 'user' => Set['password', 'password_confirmation'] },
                     :only => :create )
  param_accessible({ 'id'         => true,
                     'user' => Set['current_password', 'new_password',
                       'new_password_confirmation'] },
                     :only => :update )

  # param_accessible( { 'user' => Set[] }, :only => :index ) # experimenting

  def index
    @query_type = params[:query_type]
    @submit_button = params[:button]
    params.except!(:query_type, :commit, :button)

    if @query_type == 'filter' && @submit_button == 'clear_button'
      params.delete(:filter)
    end

    case request.format
    when Mime::HTML
      @attributes = [:username,
                     :full_name,
                     :account_deactivated,
                     :admin,
                     :manager,
                     :secretary,
                     :a_person]
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML
      @attributes = [:username,
                     :full_name,
                     :email,
                     :account_deactivated,
                     :admin,
                     :manager,
                     :secretary,
                     :a_person]
    end

    set_column_types

    @users = UserResource.scoped

    # Filter:
    @users = UserResource.filter(@users, params[:filter], @attributes)
    @filtering_values = UserResource.last_filter_values

    # Sort:
    UserResource.all_sorting_columns = @attributes
    sort_params = (params[:sort] && params[:sort][:users]) || {}
    @users = UserResource.sort(@users, sort_params)
    @sorting_column = UserResource.last_sort_column
    @sorting_direction = UserResource.last_sort_direction

    # Compose mailing list:
    if params[:list_email_addresses]
      @mailing_list_users = @users.select { |user| !user.email.blank? }
      @mailing_list = @mailing_list_users.collect(&:formatted_email).join(', ')
    end

    set_column_headers

    respond_to do |requested_format|
      requested_format.html do

        # Paginate:
        @users = paginate(@users)

        # @title = t('admin.users.index.title')  # or: UserResource.model_name.human.pluralize
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
        render_ms_excel_2003_xml_for_download\
            @users,
            @attributes,
            @column_headers  # defined in ApplicationController
      end

      requested_format.csv do
        render_csv_for_download\
            @users,
            @attributes,
            @column_headers  # defined in ApplicationController
      end
    end
  end

  def show
    @user = UserResource.find(params[:id])

    @main_attributes = [:username,
                        :full_name,
                        :email,
                        :account_deactivated,
                        :admin,
                        :manager,
                        :secretary,
                        :a_person]
    @main_attributes << :person_id if @user.a_person?
    @main_attributes << :comments

    @other_attributes = []
    @other_attributes << :last_signed_in_at\
        unless @user.last_signed_in_at.blank?

    @safe_ips_attributes = [:ip, :description]

    ip_sort_params = (params[:sort] && params[:sort][:safe_ips]) || {}
    @safe_ips = KnownIPResource.sort(@user.safe_ips, ip_sort_params)
    @sorting_column = KnownIPResource.last_sort_column
    @sorting_direction = KnownIPResource.last_sort_direction

    set_column_types
    set_column_headers
    set_known_ips_column_types
    set_known_ips_column_headers

    @title = t('admin.users.show.title', :username => @user.username)
  end

  def new
    @user = UserResource.new

    render_new_properly
  end

  def edit
    @user = UserResource.find(params[:id])

    render_edit_properly
  end

  def create

    params[:user][:safe_ip_ids] ||= []

    params[:user].delete(:email)\
        if params[:user][:email].blank?

    params[:user].delete(:comments)\
        if params[:user][:comments].blank?

    @user = UserResource.new(params[:user])

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
    @user = UserResource.find(params[:id])

    params[:user][:safe_ip_ids] ||= []

    params[:user].delete(:email)\
        if params[:user][:email].blank?

    params[:user].delete(:comments)\
        if params[:user][:comments].blank?

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
                           :username => @user.username)
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
    @user = UserResource.find(params[:id])
    @user.destroy
    flash[:notice] = t('flash.admin.users.destroy.success',
                       :username => @user.username)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      set_column_types
      set_column_headers
      # NOTE: this seems redundant because coincides with KnownIP.all_sorting_columns
      @known_ips_attributes = [:ip, :description]
      set_known_ips_column_types
      set_known_ips_column_headers

      @safe_ips = nil
      ip_sort_params = (params[:sort] && params[:sort][:safe_ips]) || {}
      @other_ips = KnownIPResource.sort(KnownIPResource.scoped, ip_sort_params)
      @sorting_column = KnownIPResource.last_sort_column
      @sorting_direction = KnownIPResource.last_sort_direction

      @title = t('admin.users.new.title')

      render :new
    end

    def render_edit_properly
      set_column_types
      set_column_headers
      @known_ips_attributes = [:ip, :description]
      set_known_ips_column_types
      set_known_ips_column_headers

      ip_sort_params = (params[:sort] && params[:sort][:safe_ips]) || {}
      @safe_ips = KnownIPResource.sort(@user.safe_ips, ip_sort_params)
      @other_ips = KnownIPResource.sort(KnownIPResource.scoped, ip_sort_params) -
        @safe_ips
      @sorting_column = KnownIPResource.last_sort_column
      @sorting_direction = KnownIPResource.last_sort_direction

      @title = t('admin.users.edit.title', :username => @user.username)

      render :edit
    end

    def set_column_types
      @column_types = {}
      UserResource.columns_hash.each do |key, value|
        @column_types[key.to_sym] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = UserResource.human_attribute_name(attr)

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

    def set_known_ips_column_types
      @known_ips_column_types = {}
      KnownIPResource.columns_hash.each do |key, value|
        @known_ips_column_types[key.to_sym] = value.type
      end
    end

    def set_known_ips_column_headers
      @known_ips_column_headers = {}
      @known_ips_column_types.each do |attr, type|
        human_name = KnownIPResource.human_attribute_name(attr)

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
