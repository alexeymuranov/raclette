class AdminController < ApplicationController

  before_filter :require_admin_login  

  private
  
    def require_admin_login
      unless current_user.admin?
        flash[:error] = "You must be an admin to access the section you tried to access"
        redirect_to root_url
      end
    end
end