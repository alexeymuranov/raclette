require 'test_helper'

class LessonSupervisionsControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    @lesson_supervision = lesson_supervisions(:one)
    test_log_in(@user_admin, :secretary, "127.0.0.1")
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => @lesson_supervision.to_param }
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @lesson_supervision.to_param }
    assert_response :success
  end
end
