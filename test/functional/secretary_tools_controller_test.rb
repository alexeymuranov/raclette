require 'test_helper'

class SecretaryToolsControllerTest < ActionController::TestCase

  def setup
    test_log_in(admin_users(:one), "127.0.0.1")
  end

  test "should get overview" do
    get :overview
    assert_response :success
  end

end
