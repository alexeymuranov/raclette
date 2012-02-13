## encoding: UTF-8

require 'set'  # to be able to use Set
require 'app_utilities/active_model_utilities'

module Accessors
  module KnowingYourController
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_accessor :controller_class  # To be redefined in classes

      def controller_path
        controller_class.controller_path
      end
    end

    def controller_path
      self.class.controller_path
    end
  end

  class KnownIPResource < Admin::KnownIP
    include ActiveModelUtilities
    include KnowingYourController

    # Redefine class name of the associated model:
    has_many :safe_users, :class_name => :UserResource,
                          :through    => :safe_user_ips,
                          :source     => :user

    def self.controller_class
      @controller_class || Admin::KnownIPsController
    end
  end

  class UserResource < Admin::User
    include ActiveModelUtilities
    include KnowingYourController

    has_many :safe_ips, :class_name => :KnownIPResource,
                        :through    => :safe_user_ips,
                        :source     => :known_ip

    def self.controller_class
      @controller_class || Admin::UsersController
    end
  end

  class EventResource < Event
    include ActiveModelUtilities
    include KnowingYourController

    def self.controller_class
      @controller_class || EventsController
    end
  end

  class GuestResource < Guest
    include ActiveModelUtilities
  end

  class InstructorResource < Instructor
    include ActiveModelUtilities
    include KnowingYourController

    belongs_to :person, :class_name => :PersonResource,
                        :inverse_of => :instructor

    def self.controller_class
      @controller_class || InstructorsController
    end
  end

  class MemberResource < Member
    include ActiveModelUtilities
    include KnowingYourController

    belongs_to :person, :class_name => :PersonResource,
                        :inverse_of => :member

    def self.controller_class
      @controller_class || MembersController
    end
  end

  class PersonResource < Person
    include ActiveModelUtilities
    include KnowingYourController
  end
end
