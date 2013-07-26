require 'test_helper'

class RegisterControllerTest < ActionController::TestCase

  def setup
    @user_admin = admin_users(:one)
    @member = members(:one)
    @event = events(:one)
    test_log_in(@user_admin, :secretary, "127.0.0.1")
  end

  test "should get choose_person" do
    get :choose_person
    assert_response :success
  end

  test "should get new_member_transaction" do
    get :new_member_transaction, { 'member_id' => @member.to_param }
    assert_response :success
  end

  test "should get new_member_transaction each tab" do
    [ 'new_entry', 'new_ticket_purchase', 'new_membership_purchase'
    ].each do |tab|
      get :new_member_transaction,
          { 'member_id' => @member.to_param, 'tab' => tab }
      assert_response :success
    end
  end

  test "should get new_guest_transaction" do
    get :new_guest_transaction,
        { 'guest' => { 'first_name' => 'X', 'last_name' => 'Yz' } }
    assert_response :success
  end

  test "should get new_guest_transaction each tab" do
    [ 'new_entry', 'new_ticket_purchase', 'new_membership_purchase'
    ].each do |tab|
      get :new_guest_transaction,
          { 'guest' => { 'first_name' => 'Ab' }, 'tab' => tab }
      assert_response :success
    end
  end

  test "should create member_entry" do
    assert_difference('MemberEntry.count') do
      assert_difference('EventEntry.count') do
        post :create_member_entry,
             { 'member_id'   => @member.to_param,
               'event_entry' =>
                 { 'event_id' => @event.to_param } }
      end
    end

    assert_redirected_to register_choose_person_path
  end

  test "should create guest_event_entry" do
    assert_difference('GuestEntry.count') do
      assert_difference('EventEntry.count') do
        post :create_guest_entry,
             { 'guest'       => { 'first_name' => 'X', 'last_name'  => 'Yz' },
               'event_entry' => { 'event_id' => @event.to_param } }
      end
    end

    assert_redirected_to register_choose_person_path
  end

  test "should create anonymous_event_entry" do
    assert_difference('EventEntry.count') do
      post :create_anonymous_entry,
           { 'event_entry' => { 'event_id' => @event.to_param } }
    end

    assert_redirected_to register_choose_person_path
  end

  test "should create member_ticket_purchase" do
    selected_ticket_book = ticket_books(:one)
    assert_difference('@member.payed_tickets_count', selected_ticket_book.tickets_number) do
      assert_difference('TicketsPurchase.count') do
        post :create_member_ticket_purchase,
             { 'member_id'        => @member.to_param,
               'tickets_purchase' =>
                 { 'ticket_book_id' => selected_ticket_book.to_param } }
        @member.reload
      end
    end

    assert_redirected_to register_choose_person_path
  end

  test "should create member_membership_purchase" do
    selected_membership = memberships(:three)
    assert_difference('MembershipPurchase.count') do
      assert_difference('MemberMembership.count') do
        post :create_member_membership_purchase,
             { 'member_id'           => @member.to_param,
               'membership_purchase' =>
                 { 'membership_id' => selected_membership.to_param } }
      end
    end

    assert_redirected_to register_choose_person_path
  end
end
