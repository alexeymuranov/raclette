require 'test_helper'

class MonitorControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get overview" do
    session[:user_id] = @user_admin.to_param
    get :overview
    assert_response :success
  end
end
