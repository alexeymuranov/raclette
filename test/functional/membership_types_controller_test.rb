require 'test_helper'

class MembershipTypesControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    @membership_type = membership_types(:one)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get index" do
    session[:user_id] = @user_admin.to_param
    get :index
    assert_response :success
  end

  test "should get show" do
    session[:user_id] = @user_admin.to_param
    get :show, { :id => @membership_type.to_param }
    assert_response :success
  end

  test "should get new" do
    session[:user_id] = @user_admin.to_param
    get :new
    assert_response :success
  end

  test "should get edit" do
    session[:user_id] = @user_admin.to_param
    get :edit, { :id => @membership_type.to_param }
    assert_response :success
  end
end
