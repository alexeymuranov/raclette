require 'test_helper'

class Admin::AdminToolsControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get overview" do
    get :overview, {}, { :user_id => @user_admin.to_param }
    assert_response :success
  end
end
