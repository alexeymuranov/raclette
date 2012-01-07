require 'test_helper'

class Admin::AdminToolsControllerTest < ActionController::TestCase

  def setup
    @user = admin_users(:one)
    test_log_in(@user, "127.0.0.1")
  end

  test "should get overview" do
    get :overview
    assert_response :success
  end
end
