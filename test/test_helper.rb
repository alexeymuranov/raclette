ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  set_fixture_class :'admin/known_ips'     => Admin::KnownIP,
                    :'admin/safe_user_ips' => Admin::SafeUserIP,
                    :application_journal   => ApplicationJournalRecord

  # Add more helper methods to be used by all tests here...

  def log_in(user, client_ip)
    controller.log_in(user, client_ip)
  end
end
