require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  def setup
    @person = people(:one)
  end

  test "pseudo columns must work" do
    assert_not_nil Person.sql_for_columns[:full_name]
    assert_not_nil Person.column_db_types[:full_name]
    assert_not_nil Person.with_pseudo_columns(:full_name).first.full_name
  end

  test "should attend events" do
    member = members(:one)
    member_entry = member.member_entries.create!(:tickets_used => 1)
    guest = Guest.new(:first_name => 'X', :last_name  => 'Yz')
    guest_entry = GuestEntry.new(guest.attributes)
    assert_difference('EventEntry.count', 2) do
      entry = @person.attend_event(events(:one), member_entry)
      assert_kind_of EventEntry, entry
      entry = @person.attend_event(events(:current), guest_entry)
      assert_kind_of EventEntry, entry
    end
  end
end

# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  last_name          :string(32)       not null
#  first_name         :string(32)       not null
#  name_title         :string(16)
#  nickname_or_other  :string(32)       default(""), not null
#  birthyear          :integer
#  email              :string(255)
#  mobile_phone       :string(32)
#  home_phone         :string(32)
#  work_phone         :string(32)
#  primary_address_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

