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
    @guest = Guest.new
  end

  # def test_respond_to_attributes_method
  #   assert_respond_to @guest, :attributes
  # end
end
