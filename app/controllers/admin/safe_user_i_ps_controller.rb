## encoding: UTF-8

class Admin::SafeUserIPsController < AdminController
  # POST /admin/safe_user_ips
  # POST /admin/safe_user_ips.xml
  def create
    @safe_user_ip = Admin::SafeUserIP.new(params[:admin_safe_user_ip])

    respond_to do |format|
      if @safe_user_ip.save
        format.html { redirect_to(@safe_user_ip,
                        :notice => 'Safe User IP was successfully created.') }
        format.xml  { render :xml => @safe_user_ip,
                             :status => :created,
                             :location => @safe_user_ip }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @safe_user_ip.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/safe_user_ips/1
  # DELETE /admin/safe_user_ips/1.xml
  def destroy
    @safe_user_ip = Admin::SafeUserIP.find(params[:id])
    @safe_user_ip.destroy

    respond_to do |format|
      format.html { redirect_to(admin_safe_user_ips_url) }
      format.xml  { head :ok }
    end
  end
end
