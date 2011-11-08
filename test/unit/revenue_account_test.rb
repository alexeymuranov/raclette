require 'test_helper'

class RevenueAccountTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: revenue_accounts
#
#  id                 :integer         not null, primary key
#  unique_title       :string(64)      not null
#  locked             :boolean         default(FALSE), not null
#  activity_period_id :integer
#  opened_on          :date
#  closed_on          :date
#  main               :boolean         default(FALSE), not null
#  amount             :decimal(7, 2)   default(0.0), not null
#  amount_updated_on  :date
#  description        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

