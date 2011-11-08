require 'test_helper'

class TicketsPurchaseTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: tickets_purchases
#
#  id             :integer         not null, primary key
#  member_id      :integer         not null
#  tickets_number :integer(2)      not null
#  ticket_book_id :integer
#  purchase_date  :date            not null
#  created_at     :datetime
#  updated_at     :datetime
#

