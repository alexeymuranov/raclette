## encoding: UTF-8

module SessionsHelper

  def log_in(user, client_ip)
    user.last_signed_in_at = Time.now
    user.last_signed_in_from_ip = client_ip
    user.save
    # cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    session[:client_ip] = client_ip
    self.current_user = user
  end

  def current_user=(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def current_user
    @current_user ||= user_from_session
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def require_login  # before filter
    deny_access unless logged_in?
  end

  def deny_access
    store_location_to_return_to
    flash[:alert] = t('flash.filters.require_login')
    redirect_to login_path
  end

  def redirect_back_or_to(default)
    redirect_to(path_to_return_to || default)
    clear_return_to
  end

  def current_event=(event)
    @current_event_id = event.id
    session[:current_event_id] = @current_event_id
    @current_event = event
  end

  def current_event
    if current_event_id
      @current_event ||= Event.find(current_event_id)
    end
  end

  def current_event_id
    @current_event_id ||= current_event_id_from_session
  end

  private

    # def user_from_remember_token
    #   Admin::User.authenticate_with_salt(*remember_token)
    # end

    def user_from_session
      # raise session.inspect
      Admin::User.find(session[:user_id]) if session[:user_id]
    end

    def current_event_id_from_session
      session[:current_event_id]
    end

    # def remember_token
    #   cookies.signed[:remember_token] || [nil, nil]
    # end

    def store_location_to_return_to
      session[:return_to] = request.fullpath
    end

    def clear_return_to
      session[:return_to] = nil
    end

    def path_to_return_to
      session[:return_to]
    end

end
