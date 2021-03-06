## encoding: UTF-8

class SessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  def new
    # @session = ActiveRecord::SessionStore::Session.new  # how to use SessionStore?
    render_new_properly
  end

  def create
    user = Admin::User.authenticate(params[:username], params[:password])

    if user
      unless user.account_deactivated?
        if role = user.has_role?(params[:role])
          client_ip = request.remote_ip.force_encoding('UTF-8')
          path = path_to_return_to
          # clear_return_to  # redundant with reset_session
          reset_session  # security measure
          log_in(user, role, client_ip)

          flash[:info] = t('flash.sessions.create.logged_in',
                           :username => user.username)

##  It is possible to use HTML in the message, however:
### XXX NOTE Security Warning:
###   Need to be sure that 'flash.sessions.create.logged_in' translations
###   are HTML safe
### XXX NOTE: not good for non-admin users
#         flash[:info] = t('flash.sessions.create.logged_in',
#                          :username => "<a href=\"#{admin_user_path(user)}\">"\
#                                       "#{CGI.escapeHTML(user.username)}"\
#                                       "</a>").html_safe
###

          redirect_to(path || root_url)
        else
          flash.now.alert = t('flash.sessions.create.user_role_not_active',
                              :role            => params[:role],
                              :available_roles => user.roles.to_s)
          render_new_properly
        end
      else
        flash.now.alert = t('flash.sessions.create.user_account_deactivated')
        render_new_properly
      end
    else
      flash.now.alert = t('flash.sessions.create.invalid_login')
      render_new_properly
    end
  end

  def destroy
    # log_out  # redundant with reset_session
    reset_session  # security measure
    flash[:info] = t('flash.sessions.destroy.logged_out')
    redirect_to login_url
  end

  private

    def render_new_properly
      @client_ip = request.remote_ip
      @title = t('sessions.new.title')

      @roles = [:secretary, :manager, :admin]

      render :new
    end

end
