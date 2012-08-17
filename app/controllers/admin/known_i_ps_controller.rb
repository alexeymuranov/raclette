## encoding: UTF-8

class Admin::KnownIPsController < AdminController

  class User < Accessors::User
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

  class KnownIP < Accessors::KnownIP
    has_many :safe_users, :class_name => :User,
                          :through    => :safe_user_ips,
                          :source     => :user

    self.all_sorting_columns = [:ip, :description]
    self.default_sorting_column = :ip
  end

  def index
    @attributes = [:ip, :description]

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
    @attributes = [:ip, :description]

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
      @title = t('admin.known_i_ps.new.title')

      render :new
    end

    def render_edit_properly
      @title = t('admin.known_i_ps.edit.title', :ip => @known_ip.ip)

      render :edit
    end

end
