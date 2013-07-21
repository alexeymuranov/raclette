require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  def setup
    @user_admin = admin_users(:one)
    @person = people(:one)
    test_log_in(@user_admin, :secretary, "127.0.0.1")
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => @person.to_param }
    assert_response :success
  end
end
