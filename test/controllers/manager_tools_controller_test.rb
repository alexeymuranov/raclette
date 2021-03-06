require 'test_helper'

class ManagerToolsControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    test_log_in(@user_admin, :manager, "127.0.0.1")
  end

  test "should get overview" do
    get :overview
    assert_response :success
  end
end
