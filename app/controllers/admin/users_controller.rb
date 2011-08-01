## encoding: UTF-8

class Admin::UsersController < AdminController

  # To be used with respond_with, but currently useless: 
  # respond_to :html, :js, :xml, :ms_excel_2003_xml, :csv, :only => :index

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

    @column_types_o_hash = ActiveSupport::OrderedHash.new
    @attributes.each do |attr|
      @column_types_o_hash[attr] = Admin::User.columns_hash[attr.to_s].type
    end

    # Filter:
    params[:filter] ||= {}
    @filter = {}

    @all_filtered_users = Admin::User.scoped

    @column_types_o_hash.each do |attr, col_type|
      case col_type
      when :string
        unless params[:filter][attr].blank?
          @filter[attr] = params[:filter][attr].sub(/\%*\z/, '%')
          # @users = @users.where(Admin::User.arel_table[attribute].matches(@filter[attr]).to_sql)
          # Use MetaWhere instead:
          @all_filtered_users = @all_filtered_users.where(attr.matches => @filter[attr])
        end
      when :boolean
        case params[:filter][attr]
        when 'yes'
          @filter[attr] = true
          @all_filtered_users = @all_filtered_users.where(attr => true)
        when 'no'
          @filter[attr] = false
          @all_filtered_users = @all_filtered_users.where(attr => false)
        end
      end
    end

    # Sort:
    @all_filtered_users = @all_filtered_users.order(sort_sql(:users))

    # Paginate:
    params[:per_page] ||= 25
    @users = @all_filtered_users.page(params[:page]).per(params[:per_page])

    # Compose mailing list:
    if params[:list_email_addresses]
      @mailing_list_users = @all_filtered_users.select { |user| !user.email.blank? }
      @mailing_list = @mailing_list_users.collect(&:formatted_email).join(', ')
    end

    @title = t('admin.users.index.title')  # or: Admin::User.human_name.pluralize

    @attributes_for_download = [ :username,
                                 :full_name,
                                 :email,
                                 :account_deactivated,
                                 :admin,
                                 :manager,
                                 :secretary,
                                 :a_person ]

    @column_types_for_download_o_hash = ActiveSupport::OrderedHash.new
    @attributes_for_download.each do |attr|
      @column_types_for_download_o_hash[attr] = Admin::User.columns_hash[attr.to_s].type
    end

    # respond_with(@all_filtered_users) do |requested_format|

    respond_to do |requested_format|
      requested_format.html do
        render :index
      end

      requested_format.xml do
        render :xml => @all_filtered_users, :only => @attributes_for_download
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

      requested_format.ms_excel_2003_xml do  # renders .ms_excel_2003_xml.builder template
        send_data render_to_string( :template => 'shared/index',
                                    :locals   => { :models              => @all_filtered_users,
                                                   :column_types_o_hash => @column_types_for_download_o_hash }),
                  :filename    => "#{Admin::User.human_name.pluralize}"\
                                  " #{Time.now.strftime('%Y-%m-%d %k_%M')}"\
                                  ".excel2003.xml",
                  :type        => "#{Mime::MS_EXCEL_2003_XML.to_s}; "\
                                  "charset=utf-8",
                  :disposition => 'inline'
      end

      requested_format.csv do
        send_data csv_from_collection(Admin::User,
                                      @all_filtered_users,
                                      :only     => @attributes_for_download,
                                      :col_sep  => ';',
                                      :row_sep  => "\r\n",
                                      :encoding => 'utf-8'),
                  :filename    => "#{Admin::User.human_name.pluralize}"\
                                  " #{Time.now.strftime('%Y-%m-%d %k_%M')}"\
                                  ".csv",
                  :type        => "#{Mime::CSV.to_s}; charset=utf-8",
                  :disposition => 'inline'
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
    @other_attributes << :last_signed_in_at unless @user.last_signed_in_at.blank?

    @safe_ips_attributes = [ :ip, :description ]
    @safe_ips_column_types_o_hash = ActiveSupport::OrderedHash.new
    @safe_ips_attributes.each do |attr|
      @safe_ips_column_types_o_hash[attr] = Admin::KnownIP.columns_hash[attr.to_s].type
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

    @acceptable_attribute_names = [ 'username', 'full_name', 'email',
        'account_deactivated', 'admin', 'manager', 'secretary', 'a_person',
        'comments',
        'password', 'password_confirmation',
        'safe_ip_ids' ]

    params[:admin_user].slice!(*@acceptable_attribute_names)

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

    @acceptable_attribute_names = [ 'username', 'full_name', 'email',
        'account_deactivated', 'admin', 'manager', 'secretary', 'a_person',
        'comments',
        'current_password', 'new_password', 'new_password_confirmation',
        'safe_ip_ids' ]

    params[:admin_user].slice!(*@acceptable_attribute_names)

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
      params = {}

      @known_ips_attributes = [ :ip, :description ]
      @known_ips_column_types_o_hash = ActiveSupport::OrderedHash.new
      @known_ips_attributes.each do |attr|
        @known_ips_column_types_o_hash[attr] = Admin::KnownIP.columns_hash[attr.to_s].type
      end

      @safe_ips = nil
      @other_ips = Admin::KnownIP.order(sort_sql(:safe_ips))

      @title = t('admin.users.new.title')

      render :new
    end

    def render_edit_properly
      params = {}

      @known_ips_attributes = [ :ip, :description ]
      @known_ips_column_types_o_hash = ActiveSupport::OrderedHash.new
      @known_ips_attributes.each do |attr|
        @known_ips_column_types_o_hash[attr] = Admin::KnownIP.columns_hash[attr.to_s].type
      end

      @safe_ips = @user.safe_ips.order(sort_sql(:safe_ips))
      @other_ips = Admin::KnownIP.order(sort_sql(:safe_ips)) - @safe_ips

      @title =  t('admin.users.edit.title', :username => @user.username)

      render :edit
    end

end
