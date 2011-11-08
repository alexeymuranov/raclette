require 'test_helper'

class MembersControllerTest < ActionController::TestCase

  setup do
    @member = members(:one)
  end

  test "should get index" do
    get :index, {}, { :user_id => 1 }
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => @member.to_param }, { :user_id => 1 }
    assert_response :success
  end

  test "should get new" do
    get :new, {}, { :user_id => 1 }
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :id => @member.to_param }, { :user_id => 1 }
    assert_response :success
  end

end
