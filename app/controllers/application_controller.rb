## encoding: UTF-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include SessionsHelper
  
  before_filter :require_login  
  before_filter :set_locale

  def set_locale
    # if params[:locale] is nil, then I18n.default_locale will be used
    I18n.locale = params[:locale]
  end
  
  private
  
    def sort_direction  
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc' 
    end

end
