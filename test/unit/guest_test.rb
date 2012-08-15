# Test non-ActiveRecord model Guest
# See http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/

require 'test_helper'

class GuestActiveModelComplianceTest < ActiveModel::TestCase
  include ActiveModel::Lint::Tests

  def setup
    @model = Guest.new
  end
end

class GuestTest < ActiveSupport::TestCase
  def setup
    @guest = Guest.new(:first_name => 'X', :last_name  => 'Yz')
  end

  test "should attend events" do
    @event = events(:one)
    assert_difference('GuestEntry.count') do
      assert_difference('EventEntry.count') do
        entry = @guest.attend_event(@event)
        assert_kind_of GuestEntry, entry
      end
    end
  end
end
