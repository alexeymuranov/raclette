## encoding: UTF-8

class Admin::UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = Admin::User.all

    @title = t('admin.users.index.title')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = Admin::User.find(params[:id])

    @title = t('admin.users.show.title', :username => @user.username)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = Admin::User.new

    @title = t('admin.users.new.title')

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = Admin::User.find(params[:id])
 
    @title = t('admin.users.edit.title', :username => @user.username)

 end

  # POST /users
  # POST /users.xml
  def create
    @user = Admin::User.new(params[:admin_user])

    respond_to do |format|
      if @user.save
        flash[:success] = t('admin.users.create.flash.success',
                                :username => @user.username)
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        flash[:error] = t('admin.users.create.flash.failure')
        @title = t('admin.users.new.title')
        format.html { render :action => :new }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = Admin::User.find(params[:id])

    params[:admin_user].delete(:password)\
        if params[:admin_user][:password].blank?
        
    if params[:admin_user][:new_password].blank?
      params[:admin_user].delete(:new_password)
      params[:admin_user].delete(:new_password_confiramtion)
    end
      
    password = params[:admin_user][:password]
    new_password = params[:admin_user][:new_password]
    
    if new_password.nil? || @user.has_password?(password)
      respond_to do |format|
        if @user.update_attributes(params[:admin_user])
          flash[:success] =  t('admin.users.update.flash.success',
                                   :username => @user.username)
          format.html { redirect_to(@user) }
          format.xml  { head :ok }
        else
          flash.now[:error] = t('admin.users.update.flash.failure')
          @title =  t('admin.users.edit.title', :username => @user.username)
          format.html { render :action => 'edit' }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    else
      flash.now[:error] = t('admin.users.update.flash.wrong_password')
      @title =  t('admin.users.edit.title', :username => @user.username)
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = Admin::User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(admin_users_url) }
      format.xml  { head :ok }
    end
  end
end
