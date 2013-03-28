require 'test_helper'

class Admin::KnownIPsControllerTest < ActionController::TestCase

  setup do
    @user_admin = admin_users(:one)
    @known_ip = admin_known_ips(:one)
    @new_known_ip = Admin::KnownIP.new(
        'ip'          => "64.64.64.64",
        'description' => "Another IP" )
    test_log_in(@user_admin, :admin, "127.0.0.1")
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
      post :create, { :known_ip => @new_known_ip.attributes }
    end

    assert_not_nil assigns(:known_ip)
    assert_redirected_to :action => :show, :id => assigns(:known_ip)
  end

  test "should show admin_known_ip" do
    get :show, { :id => @known_ip.to_param }
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @known_ip.to_param }
    assert_response :success
  end

  test "should update admin_known_ip" do
    put :update, { :id => @known_ip.to_param,
                   :known_ip => @new_known_ip.attributes }

    assert_not_nil assigns(:known_ip)
    assert_redirected_to :action => :show, :id => assigns(:known_ip)
  end

  test "should destroy admin_known_ip" do
    assert_difference('Admin::KnownIP.count', -1) do
      delete :destroy, { :id => @known_ip.to_param }
    end

    assert_redirected_to :action => :index
  end
end
