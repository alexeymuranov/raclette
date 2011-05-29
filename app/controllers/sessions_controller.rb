## encoding: UTF-8

class SessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  def new
    @session = ActiveRecord::SessionStore::Session.new
    @title = t('sessions.new.log_in')
    @client_ip = request.remote_ip
  end

  def create  
    user = Admin::User.authenticate(params[:username], params[:password])
    # user = Admin::User.authenticate(params[:session][:email],
    #                                 params[:session][:password])
    client_ip = request.remote_ip
    if user
      reset_session  # security measure
      # session[:user_id] = user.id
      # session[:client_ip] = client_ip
      log_in(user, client_ip)
      flash[:success] = "Logged in!" 
      redirect_back_or_to root_url 
      # redirect_to root_url 
    else  
      flash.now.alert = "Invalid email/password combination"
      @title = "Sign in"
      render 'new'  
    end  
  end  

  def destroy
    # log_out  # redundant with reset_session
    reset_session
    flash[:notice] = "Logged out" 
    redirect_to login_url
  end
end
