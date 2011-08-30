require 'test_helper'

class Admin::AdminToolsControllerTest < ActionController::TestCase

  def setup
  end

  test "should get overview" do
    get :overview
    assert_response :success
  end
end
