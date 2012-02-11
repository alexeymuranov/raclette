require 'test_helper'

class LessonSupervisionsControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    @lesson_supervision = lesson_supervisions(:one)
    # test_log_in(admin_users(:one), "127.0.0.1")
  end

  test "should get index" do
    session[:user_id] = @user_admin.to_param
    get :index
    assert_response :success
  end

  test "should get show" do
    session[:user_id] = @user_admin.to_param
    get :show, { :id => @lesson_supervision.to_param }
    assert_response :success
  end

  test "should get new" do
    session[:user_id] = @user_admin.to_param
    get :new
    assert_response :success
  end

  test "should get edit" do
    session[:user_id] = @user_admin.to_param
    get :edit, { :id => @lesson_supervision.to_param }
    assert_response :success
  end
end
