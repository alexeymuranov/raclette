require 'test_helper'

class Admin::SafeUserIPsControllerTest < ActionController::TestCase

  setup do
    @user_admin = admin_users(:one)
    @another_user = admin_users(:user_secretary)
    @known_ip = admin_known_ips(:one)
    @safe_user_ip = admin_safe_user_ips(:one)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get index" do
    session[:user_id] = @user_admin.to_param
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
    assert_not_nil assigns(:known_ips)
  end

  test "should get edit_all" do
    session[:user_id] = @user_admin.to_param
    get :edit_all, { :id => @safe_user_ip.to_param }
    assert_response :success
  end

  test "should update all safe user ips" do
    2.times do
      new_safe_user_ids_for_known_ip = @known_ip.safe_user_ids
      if new_safe_user_ids_for_known_ip.include? @another_user.id
        new_safe_user_ids_for_known_ip.delete @another_user.id
        expected_difference = -1
      else
        new_safe_user_ids_for_known_ip << @another_user.id
        expected_difference = 1
      end

      params_hash = { :safe_user_ids_for_known_ips =>
                        { @known_ip.to_param =>
                            new_safe_user_ids_for_known_ip } }

      assert_difference('@known_ip.safe_users.count', expected_difference) do
        session[:user_id] = @user_admin.to_param
        put :update_all, params_hash
      end
      assert_redirected_to admin_safe_user_ips_path
    end
  end
end
