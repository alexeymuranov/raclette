require 'test_helper'

class TicketBookTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
# == Schema Information
#
# Table name: ticket_books
#
#  id                 :integer         not null, primary key
#  membership_type_id :integer         not null
#  tickets_number     :integer(2)      not null
#  price              :decimal(4, 1)   not null
#  created_at         :datetime
#  updated_at         :datetime
#

