## encoding: UTF-8

class SessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  def new
    @session = ActiveRecord::SessionStore::Session.new
    @title = t('sessions.new.title')
    @client_ip = request.remote_ip
  end

  def create
    user = Admin::User.authenticate(params[:username], params[:password])
    # user = Admin::User.authenticate(params[:session][:email],
    #                                 params[:session][:password])
    client_ip = request.remote_ip
    if user
      unless user.account_deactivated?
        path = path_to_return_to
        # clear_return_to  # redundant with reset_session
        reset_session  # security measure
        # session[:user_id] = user.id
        # session[:client_ip] = client_ip
        log_in(user, client_ip)
        flash[:notice] = t('flash_messages.logged_in', :username => user.username)
        redirect_to(path || root_url)
      else
        flash.now.alert = t('flash_messages.user_account_deactivated')
        @title = t('sessions.new.title')
        render 'new'
      end
    else
      flash.now.alert = t('flash_messages.invalid_login')
      @title = t('sessions.new.title')
      render 'new'
    end
  end

  def destroy
    # log_out  # redundant with reset_session
    reset_session
    flash[:notice] = t('flash_messages.logged_out')
    redirect_to login_url
  end
end
