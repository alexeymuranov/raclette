require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  def setup
    @member = members(:one)
  end

  test "scopes must scope" do
    current_members_count = 0
    Member.all.each do |member|
      member.memberships.each do |membership|
        begin_date = membership.activity_period.start_date
        end_date = membership.activity_period.end_date
        today = Date.today
        if today >= begin_date && today <= end_date
          current_members_count += 1
          break
        end
      end
    end
    assert_equal Member.current.count, current_members_count
  end

  test "composite attributes must work" do
    assert_not_nil (v = Member.sql_for_columns[:tickets_count]),
      "Member.sql_for_columns[:tickets_count] is #{ v.inspect }"
    assert_not_nil (v = Member.sql_for_columns[:full_name]),
      "Member.sql_for_columns[:full_name] is #{ v.inspect }"
    assert_not_nil (v = Member.joins(:person).with_pseudo_columns(:full_name).first),
      "Member.joins(:person).with_pseudo_columns(:full_name).first is #{ v.inspect }"
    assert_not_nil (v = Member.joins(:person).with_pseudo_columns(:full_name).first.full_name),
      "Member.joins(:person).with_pseudo_columns(:full_name).first.full_name is #{ v.inspect }"
  end

  test "should attend events" do
    @event = events(:one)
    assert_difference('MemberEntry.count') do
      assert_difference('EventEntry.count') do
        entry = @member.attend_event(@event)
        assert_kind_of MemberEntry, entry
      end
    end
  end

  test "should buy tickets" do
    @ticket_book = ticket_books(:one)
    assert_difference('@member.payed_tickets_count', @ticket_book.tickets_number) do
      assert_difference('TicketsPurchase.count') do
        purchase = @member.buy_tickets(@ticket_book)
        assert_kind_of TicketsPurchase, purchase
        @member.reload
      end
    end
  end

  test "should buy membership" do
    @membership = memberships(:three)
    assert_difference('MembershipPurchase.count') do
      assert_difference('MemberMembership.count') do
        purchase = @member.buy_membership(@membership)
        assert_kind_of MembershipPurchase, purchase
      end
    end
  end
end

# == Schema Information
#
# Table name: members
#
#  person_id                         :integer          not null, primary key
#  been_member_by                    :date             not null
#  shares_tickets_with_member_id     :integer
#  account_deactivated               :boolean          default(FALSE), not null
#  latest_membership_obtained_on     :date
#  latest_membership_expiration_date :date
#  latest_membership_type            :string(32)
#  latest_membership_duration_months :integer          default(12)
#  last_card_printed_on              :date
#  last_card_delivered               :boolean          default(FALSE)
#  last_payment_date                 :date
#  last_entry_date                   :date
#  payed_tickets_count               :integer          default(0), not null
#  free_tickets_count                :integer          default(0), not null
#  created_at                        :datetime
#  updated_at                        :datetime
#

