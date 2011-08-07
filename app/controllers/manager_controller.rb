## encoding: UTF-8

class ManagerController < ApplicationController

  before_filter :require_manager_login

  private

    def require_manager_login
      unless current_user.manager?
        flash[:error] = t('flash.filters.require_manager')
        redirect_to root_url
      end
    end

end
