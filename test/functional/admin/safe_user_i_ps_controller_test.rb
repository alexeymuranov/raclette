require 'test_helper'

class Admin::SafeUserIPsControllerTest < ActionController::TestCase

  setup do
    @safe_user_ip = admin_safe_user_ips(:one)
    @user = admin_users(:one)
    test_log_in(@user, "127.0.0.1")
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
    assert_not_nil assigns(:known_ips)
  end

  # test "should create admin_safe_user_ip" do
  #   assert_difference('Admin::SafeUserIP.count') do
  #     post :create, :admin_safe_user_ip => @safe_user_ip.attributes
  #   end
  #
  #   assert_redirected_to admin_safe_user_ip_path(assigns(:admin_safe_user_ip))
  # end

  test "should get edit_all" do
    get :edit_all, :id => @safe_user_ip.to_param
    assert_response :success
  end

  test "should update all safe user ips" do
    put :update_all, :id => @safe_user_ip.to_param, :admin_safe_user_ip => @safe_user_ip.attributes
    assert_redirected_to admin_safe_user_ips_path
  end

  # test "should destroy admin_safe_user_ip" do
  #   assert_difference('Admin::SafeUserIP.count', -1) do
  #     delete :destroy, :id => @safe_user_ip.to_param
  #   end
  #
  #   assert_redirected_to admin_safe_user_ips_path
  # end
end
