require 'test_helper'

class MembershipsControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    @membership = memberships(:one)
    test_log_in(@user_admin, :manager, "127.0.0.1")
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => @membership.to_param }
    assert_response :success
  end

  test "should get new" do
    get :new, { 'activity_period_id' => activity_periods(:two).to_param,
                'membership_type_id' => membership_types(:two).to_param }
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @membership.to_param }
    assert_response :success
  end
end
