## encoding: UTF-8

class Admin::UsersController < Admin::AdminController

  USER_ATTRIBUTE_NAMES_FOR_HTML_INDEX = [ :username,
                                          :full_name,
                                          :account_deactivated,
                                          :admin,
                                          :manager,
                                          :secretary,
                                          :a_person ]
  USER_ATTRIBUTE_NAMES_FOR_XML_INDEX  = [ :username,
                                          :full_name,
                                          :email,
                                          :account_deactivated,
                                          :admin,
                                          :manager,
                                          :secretary,
                                          :a_person ]
  def index
    case request.format
    when Mime::HTML
      @attribute_names = USER_ATTRIBUTE_NAMES_FOR_HTML_INDEX
    when Mime::XML, Mime::CSV, Mime::MS_EXCEL_2003_XML,
         Mime::CSV_ZIP, Mime::MS_EXCEL_2003_XML_ZIP
      @attribute_names = USER_ATTRIBUTE_NAMES_FOR_XML_INDEX
    end

    @users = User.all

    # Filter:
    @users = do_filtering(@users)
    @filtered_users_count = @users.count

    # Sort:
    sort_params = (params['sort'] && params['sort']['users']) || {}
    @users = sort(@users, sort_params, :username)

    # Compose mailing list:
    if params['list_email_addresses']
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
               :only => @attribute_names
      end

      requested_format.js do
        case params['button']
        when 'show_email_addresses', 'hide_email_addresses'
          render :update_email_list
        end
      end

      requested_format.ms_excel_2003_xml do
        render :collection_ms_excel_2003_xml => @users,
               :only                         => @attribute_names
      end

      requested_format.csv do
        render :collection_csv => @users,
               :only           => @attribute_names
      end

      requested_format.ms_excel_2003_xml_zip do
        render :collection_ms_excel_2003_xml_zip => @users,
               :only                             => @attribute_names
      end

      requested_format.csv_zip do
        render :collection_csv_zip => @users,
               :only               => @attribute_names
      end
    end
  end

  USER_ATTRIBUTE_NAMES_FOR_SHOW = [ :username,
                                    :full_name,
                                    :email,
                                    :account_deactivated,
                                    :admin,
                                    :manager,
                                    :secretary,
                                    :a_person,
                                    :person_id,
                                    :comments ]
  def show
    @user = User.find(params['id'])

    @main_attribute_names = USER_ATTRIBUTE_NAMES_FOR_SHOW
    @main_attribute_names -= [:person_id] unless @user.a_person?

    @other_attribute_names = []
    unless @user.last_signed_in_at.blank?
      @other_attribute_names << :last_signed_in_at
    end

    @safe_ip_attribute_names = [:ip, :description]

    ip_sort_params = (params['sort'] && params['sort']['safe_ips']) || {}
    @safe_ips = sort(@user.safe_ips, ip_sort_params, :ip)

    @known_ips_column_headers = KnownIP.human_column_headers

    @title = t('admin.users.show.title', :username => @user.username)
  end

  USER_ATTRIBUTE_NAMES_FOR_NEW = [ :username,
                                   :full_name,
                                   :a_person,
                                   :email,
                                   :account_deactivated,
                                   :admin,
                                   :manager,
                                   :secretary,
                                   :comments,
                                   :safe_ip_ids,
                                   :password,
                                   :password_confirmation ]
  USER_PERSON_ATTRIBUTE_NAMES_FOR_NEW = [ :name_title,
                                          :first_name,
                                          :last_name,
                                          :nickname_or_other,
                                          :email ]
  def new
    @user = User.new

    render_new_properly
  end

  USER_ATTRIBUTE_NAMES_FOR_EDIT = [ :username,
                                    :full_name,
                                    :a_person,
                                    :email,
                                    :account_deactivated,
                                    :admin,
                                    :manager,
                                    :secretary,
                                    :comments,
                                    :safe_ip_ids,
                                    :new_password,
                                    :new_password_confirmation ]
  USER_PERSON_ATTRIBUTE_NAMES_FOR_EDIT = [ :name_title,
                                           :first_name,
                                           :last_name,
                                           :nickname_or_other,
                                           :email ]
  def edit
    @user = User.find(params['id'])

    render_edit_properly
  end

  def create
    attributes = process_raw_user_attributes_for_create

    @user = User.new(attributes)

    if @user.save
      flash[:success] = t('flash.admin.users.create.success',
                          :username => @user.username)
      redirect_to :action => :show, :id => @user
    else
      flash.now[:error] = t('flash.admin.users.create.failure')

      render_new_properly
    end
  end

  def update
    @user = User.find(params['id'])

    attributes = process_raw_user_attributes_for_update

    if @user == current_user && params['change_password']
      unless @user.has_password?(params['current_password'])
        flash.now[:error] = t('flash.admin.users.update.wrong_password')

        render_edit_properly
        return
      end
    else
      attributes.except!(:new_password, :new_password_confirmation)
    end

    if @user.update_attributes(attributes)
      flash[:notice] = t('flash.admin.users.update.success',
                         :username => @user.username )
      redirect_to :action => :show, :id => @user
    else
      flash.now[:error] = t('flash.admin.users.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @user = User.find(params['id'])

    @user.destroy

    flash[:notice] = t('flash.admin.users.destroy.success',
                       :username => @user.username)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      @known_ip_attribute_names = [:ip, :description]

      ip_sort_params = (params['sort'] && params['sort']['safe_ips']) || {}
      @known_ips = sort(KnownIP.all, ip_sort_params, :ip)
      @safe_ips = nil

      @title = t('admin.users.new.title')

      render :new
    end

    def render_edit_properly
      @known_ip_attribute_names = [:ip, :description]

      ip_sort_params = (params['sort'] && params['sort']['safe_ips']) || {}
      @known_ips = sort(KnownIP.all, ip_sort_params, :ip)
      @safe_ips = sort(@user.safe_ips, ip_sort_params, :ip)

      @title = t('admin.users.edit.title', :username => @user.username)

      render :edit
    end

  module AttributesFromParamsForCreate
    USER_ATTRIBUTE_NAMES = Set[ :username,
                                :full_name,
                                :a_person,
                                :email,
                                :account_deactivated,
                                :admin,
                                :manager,
                                :secretary,
                                :comments,
                                :safe_ip_ids,           # association attribute
                                :password,              # virtual attribute
                                :password_confirmation  # virtual attribute
                              ]
    USER_ATTRIBUTE_NAMES_FROM_STRINGS =
      USER_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def user_attribute_name_from_params_key_for_create(params_key)
        USER_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
      end

      def process_raw_user_attributes_for_create(submitted_attributes = params['user'])
        array = submitted_attributes.map { |key, value|
          [user_attribute_name_from_params_key_for_create(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          if value == '' then value = nil end
          [attr_name, value]
        }

        Hash[array].tap do |hash|
          if hash.key?(:safe_ip_ids)
            hash[:safe_ip_ids] =
              process_raw_user_safe_ip_ids_for_create(hash[:safe_ip_ids])
          end
        end
      end

      def process_raw_user_safe_ip_ids_for_create(submitted_ids = params['user']['safe_ip_ids'])
        submitted_ids.nil? ? [] : submitted_ids.map(&:to_i)
      end

  end
  include AttributesFromParamsForCreate

  module AttributesFromParamsForUpdate
    USER_ATTRIBUTE_NAMES = Set[ :username,
                                :full_name,
                                :a_person,
                                :email,
                                :account_deactivated,
                                :admin,
                                :manager,
                                :secretary,
                                :comments,
                                :safe_ip_ids,               # association attribute
                                :new_password,              # virtual attribute
                                :new_password_confirmation  # virtual attribute
                              ]
    EXCLUDED_CURRENT_USER_ATTRIBUTE_NAMES =
      Set[:account_deactivated, :admin]
    EXCLUDED_NON_CURRENT_USER_ATTRIBUTE_NAMES =
      Set[:new_password, :new_password_confirmation]
    USER_ATTRIBUTE_NAMES_FROM_STRINGS =
      USER_ATTRIBUTE_NAMES.reduce({}) { |h, attr_name|
        h[attr_name.to_s] = attr_name
        h
      }

    private

      def user_attribute_name_from_params_key_for_update(params_key)
        attribute_name = USER_ATTRIBUTE_NAMES_FROM_STRINGS[params_key]
        if @user == current_user
          unless EXCLUDED_CURRENT_USER_ATTRIBUTE_NAMES.include?(attribute_name)
            attribute_name
          end
        else
          unless EXCLUDED_NON_CURRENT_USER_ATTRIBUTE_NAMES.include?(attribute_name)
            attribute_name
          end
        end
      end

      def process_raw_user_attributes_for_update(submitted_attributes = params['user'])
        array = submitted_attributes.map { |key, value|
          [user_attribute_name_from_params_key_for_update(key), value]
        }.select { |attr_name, _|
          attr_name
        }.map { |attr_name, value|
          if value == '' then value = nil end
          [attr_name, value]
        }

        Hash[array].tap do |hash|
          if hash.key?(:safe_ip_ids)
            hash[:safe_ip_ids] =
              process_raw_user_safe_ip_ids_for_update(hash[:safe_ip_ids])
          end
        end
      end

      def process_raw_user_safe_ip_ids_for_update(submitted_ids = params['user']['safe_ip_ids'])
        submitted_ids.nil? ? [] : submitted_ids.map(&:to_i)
      end

  end
  include AttributesFromParamsForUpdate
end
