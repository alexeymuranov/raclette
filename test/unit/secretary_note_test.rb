require 'test_helper'

class SecretaryNoteTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: secretary_notes
#
#  id                 :integer          not null, primary key
#  note_type          :string(32)       not null
#  something_type     :string(32)       not null
#  something_id       :integer
#  created_on         :date             not null
#  message            :text
#  message_updated_at :datetime         not null
#  created_at         :datetime
#  updated_at         :datetime
#

