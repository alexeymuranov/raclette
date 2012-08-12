require 'test_helper'

class Admin::UserTest < ActiveSupport::TestCase

#   test "authenticate method should return nil on email/password mismatch" do
#     flunk "TODO: test empty"
#   end
#
#   test "authenticate method should return nil for an email address with no user" do
#     flunk "TODO: test empty"
#   end
#
#   test "should return the user on email/password match" do
#     flunk "TODO: test empty"
#   end

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: admin_users
#
#  id                        :integer          not null, primary key
#  username                  :string(32)       not null
#  full_name                 :string(64)       not null
#  a_person                  :boolean          not null
#  person_id                 :integer
#  email                     :string(255)
#  account_deactivated       :boolean          default(FALSE), not null
#  admin                     :boolean          default(FALSE), not null
#  manager                   :boolean          default(FALSE), not null
#  secretary                 :boolean          default(FALSE), not null
#  password_or_password_hash :string(255)      default(""), not null
#  password_salt             :string(255)
#  last_signed_in_at         :datetime
#  comments                  :text
#  created_at                :datetime
#  updated_at                :datetime
#  last_signed_in_from_ip    :string(15)
#  last_seen_at              :datetime
#

