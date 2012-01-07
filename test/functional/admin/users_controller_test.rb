require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  setup do
    @user = admin_users(:one)
    test_log_in(@user, "127.0.0.1")
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
