## encoding: UTF-8

class AdminController < ApplicationController

  before_filter :require_admin_login  

  private
  
    def require_admin_login
      unless current_user.admin?
        flash[:error] = t('flash_messages.require_admin')
        redirect_to root_url
      end
    end
end