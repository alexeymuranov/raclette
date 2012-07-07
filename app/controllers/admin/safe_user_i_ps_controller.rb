## encoding: UTF-8

class Admin::SafeUserIPsController < AdminController

  def create
    @safe_user_ip = Admin::SafeUserIP.new(params[:admin_safe_user_ip])

    if @safe_user_ip.save
      flash[:success] = "Safe User IP was successfully created."
      redirect_to @safe_user_ip
    else
      render 'new'
    end
  end

  def destroy
    @safe_user_ip = Admin::SafeUserIP.find(params[:id])
    @safe_user_ip.destroy

    redirect_to admin_safe_user_ips_url
  end
end
