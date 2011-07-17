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

    if user
      unless user.account_deactivated?
        client_ip = request.remote_ip
        path = path_to_return_to
        # clear_return_to  # redundant with reset_session
        reset_session  # security measure
        log_in(user, client_ip)

        flash[:info] = t('flash_messages.logged_in', :username => user.username)

##  Alternative:        
### XXX NOTE Security Warning:
###   Need to be sure that 'flash_messages.logged_in' translations
###   are HTML safe
#         flash[:info] = t('flash_messages.logged_in',
#                          :username => "<a href=\"#{admin_user_path(user)}\">"\
#                                       "#{CGI.escapeHTML(user.username)}"\
#                                       "</a>").html_safe
###

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
    reset_session  # security measure
    flash[:info] = t('flash_messages.logged_out')
    redirect_to login_url
  end
end
