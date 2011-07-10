## encoding: UTF-8

class Admin::KnownIPsController < AdminController
  helper_method :sort_column, :sort_direction

  def index
    @known_ips = Admin::KnownIP.order("#{sort_column} #{sort_direction}")

    @title = t('admin.known_i_ps.index.title')
  end

  def show
    @known_ip = Admin::KnownIP.find(params[:id])

    @title = t('admin.known_i_ps.show.title', :ip => @known_ip.ip)
  end

  def new
    @known_ip = Admin::KnownIP.new

    @title = t('admin.known_i_ps.new.title')
  end

  def edit
    @known_ip = Admin::KnownIP.find(params[:id])

    @title = t('admin.known_i_ps.edit.title', :ip => @known_ip.ip)
  end

  def create
    @known_ip = Admin::KnownIP.new(params[:admin_known_ip])

    if @known_ip.save
      flash[:success] =  t('admin.known_i_ps.create.flash.success', :ip => @known_ip.ip)
      redirect_to @known_ip
    else
      flash.now[:error] = t('admin.known_i_ps.create.flash.failure')
      @title = t('admin.known_i_ps.new.title')
      render 'new'
    end
  end

  def update
    @known_ip = Admin::KnownIP.find(params[:id])

    if @known_ip.update_attributes(params[:admin_known_ip])
      flash[:notice] =  t('admin.known_i_ps.update.flash.success', :ip => @known_ip.ip)
      redirect_to @known_ip
    else
      flash.now[:error] = t('admin.known_i_ps.update.flash.failure')
      @title = t('admin.known_i_ps.edit.title', :ip => @known_ip.ip)
      render 'edit'
    end
  end

  def destroy
    @known_ip = Admin::KnownIP.find(params[:id])
    @known_ip.destroy
    flash[:notice] = t('admin.known_i_ps.destroy.flash.success', :ip => @known_ip.ip)
    redirect_to admin_known_ips_url
  end
  
  private

    def sort_column  
      Admin::KnownIP.column_names.include?(params[:sort]) ? params[:sort] : 'ip'
    end
  
end
