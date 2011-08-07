## encoding: UTF-8

class Admin::KnownIPsController < AdminController

  def index
    @attributes = [ :ip, :description ]

    @column_types = {}
    @attributes.each do |attr|
      @column_types[attr] = Admin::KnownIP.columns_hash[attr.to_s].type
    end

    # Sort:
    @known_ips = sort(Admin::KnownIP.scoped, :known_ips)  # table_name = :known_ips

    # @title = t('admin.known_i_ps.index.title')
  end

  def show
    @known_ip = Admin::KnownIP.find(params[:id])
    @safe_users = @known_ip.safe_users.order(sort_sql(:safe_users))

    @key_attributes = [ :ip ]
    @other_main_attributes = [ :description ]

    @safe_users_attributes = [ :username,
                               :full_name,
                               :account_deactivated,
                               :admin,
                               :manager,
                               :secretary,
                               :a_person ]

    @safe_users_column_types = {}
    @safe_users_attributes.each do |attr|
      @safe_users_column_types[attr] =
          Admin::User.columns_hash[attr.to_s].type
    end

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
    @acceptable_attributs = [ 'ip', 'description' ]

    params[:admin_known_ip].keep_if do |key, value|
      @acceptable_attributs.include? key
    end

    @known_ip = Admin::KnownIP.new(params[:admin_known_ip])

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
    @acceptable_attributs = [ 'ip', 'description' ]

    params[:admin_known_ip].keep_if do |key, value|
      @acceptable_attributs.include? key
    end

    @known_ip = Admin::KnownIP.find(params[:id])

    if @known_ip.update_attributes(params[:admin_known_ip])
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

    def table_name_to_class(table_name)
      case table_name
      when :known_ips then Admin::KnownIP
      when :safe_users then Admin::User
      else nil
      end
    end

    def default_sort_column(table_name)
      case table_name
      when :known_ips then :ip
      when :safe_users then :username
      else nil
      end
    end

    def render_new_properly
      @title = t('admin.known_i_ps.new.title')

      render :new
    end

    def render_edit_properly
      @title = t('admin.known_i_ps.edit.title', :ip => @known_ip.ip)

      render :edit
    end

end
