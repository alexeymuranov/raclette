## encoding: UTF-8

class Admin::KnownIPsController < AdminController

  param_accessible({ 'known_ip' => Set['ip', 'description'] },
                     :only => [:create, :update] )
  param_accessible({ 'id' => true }, :only => :update )

  def index
    @attributes = [:ip, :description]

    set_column_types
    set_column_headers

    # Sort:
    @known_ips = Admin::KnownIP.scoped
    sort_params = (params[:sort] && params[:sort][:known_ips]) || {}
    @known_ips = Admin::KnownIP.sort(@known_ips, sort_params)
    @sorting_column = Admin::KnownIP.last_sort_column
    @sorting_direction = Admin::KnownIP.last_sort_direction

    # @title = t('admin.known_i_ps.index.title')
  end

  def show
    @known_ip = Admin::KnownIP.find(params[:id])
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
    Admin::User.all_sorting_columns = @safe_users_attributes
    sort_params = (params[:sort] && params[:sort][:safe_users]) || {}
    @safe_users = Admin::User.sort(@safe_users, sort_params)
    @sorting_column = Admin::User.last_sort_column
    @sorting_direction = Admin::User.last_sort_direction

    set_users_column_types
    set_users_column_headers

    @title = t('admin.known_i_ps.show.title', :ip => @known_ip.ip)
  end

  def new
    @known_ip = Admin::KnownIP.new

    render_new_properly
  end

  def edit
    @known_ip = Admin::KnownIP.find(params[:id])

    render_edit_properly
  end

  def create
    @known_ip = Admin::KnownIP.new(params[:known_ip])

    if @known_ip.save
      flash[:success] = t('flash.admin.known_i_ps.create.success',
                          :ip => @known_ip.ip)
      redirect_to @known_ip
    else
      flash.now[:error] = t('flash.admin.known_i_ps.create.failure')

      render_new_properly
    end
  end

  def update
    @known_ip = Admin::KnownIP.find(params[:id])

    if @known_ip.update_attributes(params[:known_ip])
      flash[:notice] =  t('flash.admin.known_i_ps.update.success',
                          :ip => @known_ip.ip)
      redirect_to @known_ip
    else
      flash.now[:error] = t('flash.admin.known_i_ps.update.failure')

      render_edit_properly
    end
  end

  def destroy
    @known_ip = Admin::KnownIP.find(params[:id])
    @known_ip.destroy
    flash[:notice] = t('flash.admin.known_i_ps.destroy.success',
                       :ip => @known_ip.ip)

    redirect_to admin_known_ips_url
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
      Admin::KnownIP.columns_hash.each do |key, value|
        @column_types[key.to_sym] = value.type
      end
    end

    def set_column_headers
      @column_headers = {}
      @column_types.each do |attr, type|
        human_name = Admin::KnownIP.human_attribute_name(attr)

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
      Admin::User.columns_hash.each do |key, value|
        @users_column_types[key.to_sym] = value.type
      end
    end

    def set_users_column_headers
      @users_column_headers = {}
      @users_column_types.each do |attr, type|
        human_name = Admin::User.human_attribute_name(attr)

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
