require 'test_helper'

class ActivityPeriodsControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    @activity_period = activity_periods(:one)
    test_log_in(@user_admin, :manager, "127.0.0.1")
  end

  test "should get index" do
    get :index, {}, { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => @activity_period.to_param },
               { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should get new" do
    get :new, {}, { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @activity_period.to_param },
               { :user_id => @user_admin.to_param }
    assert_response :success
  end
end
