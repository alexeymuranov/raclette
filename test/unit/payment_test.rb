require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: payments
#
#  id                       :integer         not null, primary key
#  payable_type             :string(32)      not null
#  payable_id               :integer
#  date                     :date            not null
#  amount                   :decimal(4, 1)   not null
#  method                   :string(32)      not null
#  revenue_account_id       :integer
#  payer_person_id          :integer
#  cancelled_and_reimbursed :boolean         default(FALSE), not null
#  cancelled_on             :date
#  note                     :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#

