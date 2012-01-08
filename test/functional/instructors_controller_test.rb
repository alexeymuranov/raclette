require 'test_helper'

class InstructorsControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    @instructor = instructors(:one)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get index" do
    get :index, {}, { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => @instructor.to_param },
               { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should get new" do
    get :new, {}, { :user_id => @user_admin.to_param }
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @instructor.to_param },
               { :user_id => @user_admin.to_param }
    assert_response :success
  end
end
