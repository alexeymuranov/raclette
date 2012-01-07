require 'test_helper'

class Admin::KnownIPsControllerTest < ActionController::TestCase

  setup do
    @known_ip = admin_known_ips(:one)
    @new_known_ip = Admin::KnownIP.new(
        'ip'          => "64.64.64.64",
        'description' => "Another IP" )
    @user = admin_users(:one)
    test_log_in(@user, "127.0.0.1")
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:known_ips)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_known_ip" do
    assert_difference('Admin::KnownIP.count') do
      post :create, :admin_known_ip => @new_known_ip.attributes
    end

    assert_redirected_to admin_known_ip_path(assigns(:known_ip))
  end

  test "should show admin_known_ip" do
    get :show, :id => @known_ip.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @known_ip.to_param
    assert_response :success
  end

  test "should update admin_known_ip" do
    put :update, :id => @known_ip.to_param, :admin_known_ip => @new_known_ip.attributes
    assert_redirected_to admin_known_ip_path(assigns(:known_ip))
  end

  test "should destroy admin_known_ip" do
    assert_difference('Admin::KnownIP.count', -1) do
      delete :destroy, :id => @known_ip.to_param
    end

    assert_redirected_to admin_known_ips_path
  end
end
