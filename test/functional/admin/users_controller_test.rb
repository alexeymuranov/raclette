require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  setup do
    @user_admin = admin_users(:one)
    @another_user = admin_users(:user_secretary)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get index" do
    get :index, {}, { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => @another_user.to_param },
               { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should get new" do
    get :new, {}, { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @another_user.to_param },
               { :user_id => @user_admin.to_param }
    assert_response :success
  end
end
