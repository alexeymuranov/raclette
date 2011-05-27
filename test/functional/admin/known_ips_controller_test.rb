require 'test_helper'

class Admin::KnownIpsControllerTest < ActionController::TestCase
  setup do
    @admin_known_ip = admin_known_ips(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_known_ips)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_known_ip" do
    assert_difference('Admin::KnownIp.count') do
      post :create, :admin_known_ip => @admin_known_ip.attributes
    end

    assert_redirected_to admin_known_ip_path(assigns(:admin_known_ip))
  end

  test "should show admin_known_ip" do
    get :show, :id => @admin_known_ip.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @admin_known_ip.to_param
    assert_response :success
  end

  test "should update admin_known_ip" do
    put :update, :id => @admin_known_ip.to_param, :admin_known_ip => @admin_known_ip.attributes
    assert_redirected_to admin_known_ip_path(assigns(:admin_known_ip))
  end

  test "should destroy admin_known_ip" do
    assert_difference('Admin::KnownIp.count', -1) do
      delete :destroy, :id => @admin_known_ip.to_param
    end

    assert_redirected_to admin_known_ips_path
  end
end
