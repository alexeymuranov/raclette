require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  def setup
    @user_admin = admin_users(:one)
    @person = people(:one)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get index" do
    session[:user_id] = @user_admin.to_param
    get :index
    assert_response :success
  end

  test "should get show" do
    session[:user_id] = @user_admin.to_param
    get :show, { :id => @person.to_param }
    assert_response :success
  end

end
