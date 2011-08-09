require 'test_helper'

class Admin::AdminToolsControllerTest < ActionController::TestCase
  test "should get overview" do
    get :overview
    assert_response :success
  end

end
