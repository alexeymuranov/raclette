require 'test_helper'

class MembersControllerTest < ActionController::TestCase

  setup do
    @user_admin = admin_users(:one)
    @member = members(:one)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get index" do
    get :index, {}, { :user_id => 1 }
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => @member.to_param },
               { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should get new" do
    get :new, {}, { :user_id => 1 }
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @member.to_param },
               { :user_id => @user_admin.to_param }
    assert_response :success
  end
end
