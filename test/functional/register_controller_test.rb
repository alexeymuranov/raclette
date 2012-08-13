require 'test_helper'

class RegisterControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    @member = members(:one)
    @event = events(:one)
    @ticket_book = ticket_books(:one)
    @membership_type = membership_types(:one)
    @activity_period = activity_periods(:two)
    # test_log_in(@user_admin, "127.0.0.1")
  end

  test "should get choose_person" do
    session[:user_id] = @user_admin.to_param
    get :choose_person
    assert_response :success
  end

  test "should get new_member_transaction" do
    session[:user_id] = @user_admin.to_param
    get :new_member_transaction, { :member_id => @member.to_param }
    assert_response :success
  end

  test "should get new_member_transaction each tab" do
    session[:user_id] = @user_admin.to_param
    [ 'new_entry', 'new_ticket_purchase', 'new_membership_purchase'
    ].each do |tab|
      get :new_member_transaction,
          { :member_id => @member.to_param, :tab => tab }
      assert_response :success
    end
  end

  test "should get new_guest_transaction" do
    session[:user_id] = @user_admin.to_param
    get :new_guest_transaction
    assert_response :success
  end

  test "should get new_guest_transaction each tab" do
    session[:user_id] = @user_admin.to_param
    [ 'new_entry', 'new_ticket_purchase', 'new_membership_purchase'
    ].each do |tab|
      get :new_guest_transaction,
          { :guest => { :first_name => 'Ab' }, :tab => tab }
      assert_response :success
    end
  end

  test "should create member_entry" do
    session[:user_id] = @user_admin.to_param
    assert_difference('MemberEntry.count') do
      assert_difference('EventEntry.count') do
        post :create_member_entry,
             { :member_id   => @member.to_param,
               :event_entry =>
                 { :event_id  => @event.to_param } }
      end
    end

    assert_redirected_to register_choose_person_path
  end

  test "should create guest_event_entry" do
    session[:user_id] = @user_admin.to_param
    assert_difference('GuestEntry.count') do
      assert_difference('EventEntry.count') do
        post :create_guest_entry,
             { :guest       => { :first_name => 'X', :last_name  => 'Yz' },
               :event_entry => { :event_id  => @event.to_param } }
      end
    end

    assert_redirected_to register_choose_person_path
  end

  test "should create member_ticket_purchase" do
    session[:user_id] = @user_admin.to_param
    assert_difference('@member.payed_tickets_count', @ticket_book.tickets_number) do
      assert_difference('TicketsPurchase.count') do
        post :create_member_ticket_purchase,
             { :member_id        => @member.to_param,
               :tickets_purchase =>
                 { :ticket_book_id  => @ticket_book.to_param } }
        @member.reload
      end
    end

    assert_redirected_to register_choose_person_path
  end

  test "should create member_membership_purchase" do
    session[:user_id] = @user_admin.to_param
    assert_difference('MembershipPurchase.count') do
      assert_difference('MemberMembership.count') do
        post :create_member_membership_purchase,
             { :member_id           => @member.to_param,
               :membership_purchase =>
                 { :membership =>
                     { :membership_type_id  => @membership_type.to_param,
                       :activity_period_id  => @activity_period.to_param } } }
      end
    end

    assert_redirected_to register_choose_person_path
  end
end
