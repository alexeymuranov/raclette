require 'test_helper'

class MembershipsControllerTest < ActionController::TestCase

  def setup
    test_log_in(admin_users(:one), "127.0.0.1")
  end

  test "should get index" do
    get :index
    assert_response :success
  end

#   test "should get show" do
#     get :show
#     assert_response :success
#   end

  test "should get new" do
    get :new
    assert_response :success
  end

#   test "should get edit" do
#     get :edit
#     assert_response :success
#   end

end
