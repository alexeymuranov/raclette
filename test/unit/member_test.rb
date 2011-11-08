require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
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

