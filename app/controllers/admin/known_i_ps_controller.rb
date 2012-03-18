## encoding: UTF-8

class Admin::KnownIPsController < AdminController

  class User < self::User
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

  class KnownIP < self::KnownIP
    has_many :safe_users, :class_name => :User,
                          :through    => :safe_user_ips,
                          :source     => :user

    self.all_sorting_columns = [:ip, :description]
    self.default_sorting_column = :ip
  end

  param_accessible [{ 'known_ip' => ['ip', 'description'] }],
                   :only => [:create, :update]
  param_accessible 'id', :only => :update

  def index
    @attributes = [:ip, :description]

    set_column_types
    set_column_headers

    # Sort:
    @known_ips = KnownIP.scoped
    sort_params = (params[:sort] && params[:sort][:known_ips]) || {}
    @known_ips = KnownIP.sort(@known_ips, sort_params)
    @sorting_column = KnownIP.last_sort_column
    @sorting_direction = KnownIP.last_sort_direction

    # @title = t('admin.known_i_ps.index.title')
  end

  def show
    @known_ip = KnownIP.find(params[:id])
    @attributes = [ :ip, :description ]

    @safe_users_attributes = [ :username,
                               :full_name,
                               :account_deactivated,
                               :admin,
                               :manager,
                               :secretary,
                               :a_person ]

    # Sort safe users:
    @safe_users = @known_ip.safe_users
    User.all_sorting_columns = @safe_users_attributes
    sort_params = (params[:sort] && params[:sort][:safe_users]) || {}
    @safe_users = User.sort(@safe_users, sort_params)
    @sorting_column = User.last_sort_column
    @sorting_direction = User.last_sort_direction

    set_users_column_types
    set_users_column_headers

    @title = t('admin.known_i_ps.show.title', :ip => @known_ip.ip)
  end

  def new
    @known_ip = KnownIP.new

    render_new_properly
  end

  def edit
    @known_ip = KnownIP.find(params[:id])

    render_edit_properly
  end

  def create
    @known_ip = KnownIP.new(params[:known_ip])

    if @known_ip.save
      flash[:success] = t('flash.admin.known_i_ps.create.success',
                          :ip => @known_ip.ip)
      redirect_to :action => :show, :id => @known_ip
    else
      flash.now[:error] = t('flash.admin.known_i_ps.create.failure')

      render_new_properly
    end
  end

  def update
    @known_ip = KnownIP.find(params[:id])

    if @known_ip.update_attributes(params[:known_ip])
      flash[:notice] =  t('flash.admin.known_i_ps.update.success',
                          :ip => @known_ip.ip)
      redirect_to :action => :show, :id => @known_ip
    else
      flash.now[:error] = t('flash.admin.known_i_ps.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @known_ip = KnownIP.find(params[:id])
    @known_ip.destroy
    flash[:notice] = t('flash.admin.known_i_ps.destroy.success',
                       :ip => @known_ip.ip)

    redirect_to :action => :index
  end

  private

    def render_new_properly
      set_column_types

      @title = t('admin.known_i_ps.new.title')

      render :new
    end

    def render_edit_properly
      set_column_types

      @title = t('admin.known_i_ps.edit.title', :ip => @known_ip.ip)

      render :edit
    end

    def set_column_types
      @column_types = {}
      KnownIP.columns_hash.each do |key, value|
        @column_types[key.to_sym] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = KnownIP.human_attribute_name(attr)

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

    def set_users_column_types
      @users_column_types = {}
      User.columns_hash.each do |key, value|
        @users_column_types[key.to_sym] = value.type
      end
    end

    def set_users_column_headers
      @users_column_headers = {}
      @users_column_types.each do |attr, type|
        human_name = User.human_attribute_name(attr)

        case type
        when :boolean
          @users_column_headers[attr] = I18n.t('formats.attribute_name?',
                                               :attribute => human_name)
        else
          @users_column_headers[attr] = I18n.t('formats.attribute_name:',
                                               :attribute => human_name)
        end
      end
    end

end
