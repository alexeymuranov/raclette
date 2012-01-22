require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  setup do
    @user_admin = admin_users(:one)
    @another_user = admin_users(:user_secretary)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get index" do
    session[:user_id] = @user_admin.to_param
    get :index
    assert_response :success
  end

  test "should get show" do
    session[:user_id] = @user_admin.to_param
    get :show, { :id => @another_user.to_param }
    assert_response :success
  end

  test "should get new" do
    session[:user_id] = @user_admin.to_param
    get :new
    assert_response :success
  end

  test "should get edit" do
    session[:user_id] = @user_admin.to_param
    get :edit, { :id => @another_user.to_param }
    assert_response :success
  end

  test "should update user" do
    known_ip = Admin::KnownIP.first
    2.times do
      new_secretary_status = !@another_user.secretary?
      new_safe_ip_ids = @another_user.safe_ip_ids
      if new_safe_ip_ids.include? known_ip.id
        new_safe_ip_ids.delete known_ip.id
        expected_difference = -1
      else
        new_safe_ip_ids << known_ip.id
        expected_difference = 1
      end
      params_hash = { :id         => @another_user.to_param,
                      :admin_user =>  {
                        :secretary   => new_secretary_status,
                        :safe_ip_ids => new_safe_ip_ids } }

      assert_difference('@another_user.safe_ips.count', expected_difference) do
        session[:user_id] = @user_admin.to_param
        put :update, params_hash
      end

      assert Admin::User.find(@another_user.id).secretary? == new_secretary_status
      
      assert_redirected_to @another_user
    end
  end
end
