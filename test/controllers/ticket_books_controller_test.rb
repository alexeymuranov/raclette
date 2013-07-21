require 'test_helper'

class TicketBooksControllerTest < ActionController::TestCase
  def setup
    @user_admin = admin_users(:one)
    @ticket_book = ticket_books(:one)
    @membership = memberships(:one)
    test_log_in(@user_admin, :manager, "127.0.0.1")
  end

  test "should get index" do
    get :index, { :membership_id => @membership.to_param }
    assert_response :success
  end

  test "should get show" do
    get :show, { :membership_id => @ticket_book.membership.to_param,
                 :id            => @ticket_book.to_param }
    assert_response :success
  end

  test "should get new" do
    get :new, { :membership_id => @membership.to_param }
    assert_response :success
  end

  test "should get edit" do
    get :edit, { :membership_id => @ticket_book.membership.to_param,
                 :id            => @ticket_book.to_param }
    assert_response :success
  end
end
