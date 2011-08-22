require 'test_helper'

class Admin::SafeUserIPsControllerTest < ActionController::TestCase
  setup do
    @admin_safe_user_ip = admin_safe_user_ips(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_safe_user_ips)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_safe_user_ip" do
    assert_difference('Admin::SafeUserIP.count') do
      post :create, :admin_safe_user_ip => @admin_safe_user_ip.attributes
    end

    assert_redirected_to admin_safe_user_ip_path(assigns(:admin_safe_user_ip))
  end

  test "should show admin_safe_user_ip" do
    get :show, :id => @admin_safe_user_ip.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @admin_safe_user_ip.to_param
    assert_response :success
  end

  test "should update admin_safe_user_ip" do
    put :update, :id => @admin_safe_user_ip.to_param, :admin_safe_user_ip => @admin_safe_user_ip.attributes
    assert_redirected_to admin_safe_user_ip_path(assigns(:admin_safe_user_ip))
  end

  test "should destroy admin_safe_user_ip" do
    assert_difference('Admin::SafeUserIP.count', -1) do
      delete :destroy, :id => @admin_safe_user_ip.to_param
    end

    assert_redirected_to admin_safe_user_ips_path
  end
end
