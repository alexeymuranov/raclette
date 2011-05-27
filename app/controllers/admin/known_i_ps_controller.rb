## encoding: UTF-8

class Admin::KnownIPsController < AdminController
  # GET /admin/known_ips
  # GET /admin/known_ips.xml
  def index
    @known_ips = Admin::KnownIP.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @known_ips }
    end
  end

  # GET /admin/known_ips/1
  # GET /admin/known_ips/1.xml
  def show
    @known_ip = Admin::KnownIP.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @known_ip }
    end
  end

  # GET /admin/known_ips/new
  # GET /admin/known_ips/new.xml
  def new
    @known_ip = Admin::KnownIP.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @known_ip }
    end
  end

  # GET /admin/known_ips/1/edit
  def edit
    @known_ip = Admin::KnownIP.find(params[:id])
  end

  # POST /admin/known_ips
  # POST /admin/known_ips.xml
  def create
    @known_ip = Admin::KnownIP.new(params[:admin_known_ip])

    respond_to do |format|
      if @known_ip.save
        format.html { redirect_to(@known_ip, 
                        :notice => 'Known IP was successfully created.') }
        format.xml  { render :xml => @known_ip, 
                             :status => :created,
                             :location => @known_ip }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @known_ip.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/known_ips/1
  # PUT /admin/known_ips/1.xml
  def update
    @known_ip = Admin::KnownIP.find(params[:id])

    respond_to do |format|
      if @known_ip.update_attributes(params[:admin_known_ip])
        format.html { redirect_to(@known_ip,
                        :notice => 'Known IP was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @known_ip.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/known_ips/1
  # DELETE /admin/known_ips/1.xml
  def destroy
    @known_ip = Admin::KnownIP.find(params[:id])
    @known_ip.destroy

    respond_to do |format|
      format.html { redirect_to(admin_known_ips_url) }
      format.xml  { head :ok }
    end
  end
end
