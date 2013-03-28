require 'test_helper'

class WeeklyEventsControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    @weekly_event = weekly_events(:practica_du_jeudi)
    test_log_in(@user_admin, :manager, "127.0.0.1")
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => @weekly_event.to_param }
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @weekly_event.to_param }
    assert_response :success
  end
end
