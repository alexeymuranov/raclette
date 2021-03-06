require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  def setup
    @person = people(:one)
  end

  test "pseudo columns must work" do
    assert_not_nil Person.sql_for_column(:full_name)
    assert_not_nil Person.column_db_type(:full_name)
    assert_not_nil Person.with_pseudo_columns(:full_name).first.full_name
  end

  test "should attend events" do
    assert_difference('EventEntry.count', 2) do
      entry = @person.compose_new_event_participation(events(:one), 'MemberEntry')
      assert_kind_of EventEntry, entry
      entry = @person.compose_new_event_participation(events(:current), 'GuestEntry')
      assert_kind_of EventEntry, entry
      @person.save!
    end
  end

  test "scopes must scope" do
    assert_equal Person.count, Person.members.count + Person.non_members.count
    assert_difference('Person.non_members.count', 1) do
      @person.member.delete
    end
    assert_equal Person.count, Person.members.count + Person.non_members.count
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

