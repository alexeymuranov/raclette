require 'test_helper'

class RegisterControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get choose_person" do
    session[:user_id] = @user_admin.to_param
    get :choose_person
    assert_response :success
  end

  test "should get compose_transaction" do
    session[:user_id] = @user_admin.to_param
    get :compose_transaction
    assert_response :success
  end

  # test "should create event_entry" do
  #   session[:user_id] = @user_admin.to_param
  #   post :create_event_entry
  #   assert_response :success
  # end

  # test "should create tickets_purchase" do
  #   session[:user_id] = @user_admin.to_param
  #   post :create_tickets_purchase
  #   assert_response :success
  # end

  # test "should create membership_purchase" do
  #   session[:user_id] = @user_admin.to_param
  #   post :create_membership_purchase
  #   assert_response :success
  # end
end
