## encoding: UTF-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include SessionsHelper
  
  before_filter :require_login  
  before_filter :set_locale

  helper_method :current_user
  
  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    I18n.locale = params[:locale]
  end
  
  private
  
    def require_login
      if current_user.nil?
        flash[:error] = "You must be logged in to access this section"
        redirect_to login_url
      end
    end

    def current_user
      @current_user ||= Admin::User.find(session[:user_id])\
          if session[:user_id]
    end
end
