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
    get :index, {}, { :user_id => @user_admin.to_param }
    assert_response :success
    assert_not_nil assigns(:users)
    assert_not_nil assigns(:known_ips)
  end

  test "should get edit_all" do
    get :edit_all, { 'id' => @safe_user_ip.to_param },
                   { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should update all safe user ips" do
    new_safe_user_ids_for_known_ip = @known_ip.safe_user_ids
    if new_safe_user_ids_for_known_ip.include? @another_user.id
      new_safe_user_ids_for_known_ip.delete @another_user.id
    else
      new_safe_user_ids_for_known_ip << @another_user.id
    end

    params_hash = { :safe_user_ids_for_known_ips =>
                      { @known_ip.to_param =>
                          new_safe_user_ids_for_known_ip } }

    assert_difference('Admin::SafeUserIP.count') do
      put :update_all, params_hash,
                       { :user_id => @user_admin.to_param }
    end
    assert_redirected_to admin_safe_user_ips_path
  end
end
