## encoding: UTF-8

class Admin::KnownIPsController < AdminController

  def index
    @title = 'All known IPs'
    @known_ips = Admin::KnownIP.all
  end

  def show #get
    @title = 'Known IP'
    @known_ip = Admin::KnownIP.find(params[:id])
  end

  def new
    @title = 'Create known IP'
    @known_ip = Admin::KnownIP.new
  end

  def edit #get
    @title = 'Update known IP'
    @known_ip = Admin::KnownIP.find(params[:id])
  end

  def create
    @known_ip = Admin::KnownIP.new(params[:admin_known_ip])

    if @known_ip.save
      flash[:success] = 'Known IP was successfully created.'
      redirect_to @known_ip
    else
      flash.now[:error] = 'Known IP was not created.'
      @title = 'Create known IP'
      render 'new'
    end
  end

  def update
    @known_ip = Admin::KnownIP.find(params[:id])

    if @known_ip.update_attributes(params[:admin_known_ip])
      flash[:notice] = 'Known IP was successfully updated.'
      redirect_to @known_ip
    else
      flash.now[:error] = 'Known IP was not updated.'
      @title = 'Update known IP'
      render 'edit'
    end
  end

  def destroy
    @known_ip = Admin::KnownIP.find(params[:id])
    @known_ip.destroy
    flash[:notice] = 'Known IP deleted'
    redirect_to admin_known_ips_url
  end
end
