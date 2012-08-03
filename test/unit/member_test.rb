require 'test_helper'

class MemberTest < ActiveSupport::TestCase

  test "scopes must scope" do
    current_members_count = 0
    Member.all.each do |member|
      member.memberships.each do |membership|
        begin_date = membership.activity_period.begin_date
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
    assert_not_nil (v = Member.sql_for_attributes[:tickets_count]),
      "Member.sql_for_attributes[:tickets_count] is #{ v.inspect }"
    assert_not_nil (v = Member.sql_for_attributes[:full_name]),
      "Member.sql_for_attributes[:full_name] is #{ v.inspect }"
    assert_not_nil (v = Member.joins(:person).with_composite_attributes(:full_name).first),
      "Member.joins(:person).with_composite_attributes(:full_name).first is #{ v.inspect }"
    assert_not_nil (v = Member.joins(:person).with_composite_attributes(:full_name).first.full_name),
      "Member.joins(:person).with_composite_attributes(:full_name).first.full_name is #{ v.inspect }"

  end
end
# == Schema Information
#
# Table name: members
#
#  person_id                         :integer         not null, primary key
#  been_member_by                    :date            not null
#  shares_tickets_with_member_id     :integer
#  account_deactivated               :boolean         default(FALSE), not null
#  latest_membership_obtained_on     :date
#  latest_membership_expiration_date :date
#  latest_membership_type            :string(32)
#  latest_membership_duration_months :integer(1)      default(12)
#  last_card_printed_on              :date
#  last_card_delivered               :boolean         default(FALSE)
#  last_payment_date                 :date
#  last_entry_date                   :date
#  payed_tickets_count               :integer(2)      default(0), not null
#  free_tickets_count                :integer(2)      default(0), not null
#  created_at                        :datetime
#  updated_at                        :datetime
#

