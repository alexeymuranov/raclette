## encoding: UTF-8

class SecretaryController < ApplicationController

  before_filter :require_secretary_login

  private

    def require_secretary_login
      unless current_user.secretary?
        flash[:error] = t('flash.filters.require_secretary')
        redirect_to root_url
      end
    end

end
