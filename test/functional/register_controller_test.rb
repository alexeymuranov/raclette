require 'test_helper'

class RegisterControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    # test_log_in(@user_admin, "127.0.0.1")
  end

#   test "should get choose_person" do
#     get :choose_person, {}, { :user_id => @user_admin.to_param }
#     assert_response :success
#   end

#   test "should get compose_transaction" do
#     get :compose_transaction, {}, { :user_id => @user_admin.to_param }
#     assert_response :success
#   end

#   test "should create transaction" do
#     post :create_transaction, {}, { :user_id => @user_admin.to_param }
#     assert_response :success
#   end
end
