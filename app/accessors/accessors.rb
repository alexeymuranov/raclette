## encoding: UTF-8

require 'set'
require 'app_utilities/active_model_utilities'

module Accessors
  module ControllerAware
    def self.included(base)
      base.extend(ClassMethods)

      # XXX: Looks like a hack to me, but maybe this is the official way:
      # http://api.rubyonrails.org/classes/ActionDispatch/Routing/UrlFor.html
      base.send(:include, Rails.application.routes.url_helpers)
    end

    module ClassMethods
      def controller_class  # To be redefined in classes
        @controller_class ||=
          "#{ base_class.name.pluralize }Controller".constantize
      end

      def controller_path
        @controller_path ||= controller_class.controller_path
      end
    end

    # def controller_path
    #   self.class.controller_path
    # end

    def path_to(url_options)
      url_for common_options_for_urls.merge(url_options)
    end

    private

      def common_options_for_urls
        { :controller => self.class.controller_path,
          :id         => id,
          :only_path  => true }
      end

  end

  # Active Record:
  class KnownIP < ::Admin::KnownIP
    include ActiveModelUtilities

    # XXX: this is to pick up `User` from the current scope.
    has_many :safe_users, :class_name => :User,
                          :through    => :safe_user_ips,
                          :source     => :user

    include ControllerAware

    def self.controller_class
      Admin::KnownIPsController
    end
  end

  class User < ::Admin::User
    include ActiveModelUtilities

    # XXX: this is to pick up `KnownIP` from the current scope.
    has_many :safe_ips, :class_name => :KnownIP,
                        :through    => :safe_user_ips,
                        :source     => :known_ip

    include ControllerAware

    def self.controller_class
      Admin::UsersController
    end
  end

  class ActivityPeriod < ::ActivityPeriod
    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      ActivityPeriodsController
    end
  end

  class Address < ::Address
    include ActiveModelUtilities
  end

  class ApplicationJournalRecord < ::ApplicationJournalRecord
  end

  class CommitteeMembership < ::CommitteeMembership
  end

  class Event < ::Event
    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      EventsController
    end
  end

  class EventCashier < ::EventCashier
  end

  class EventEntry < ::EventEntry
  end

  class GuestEntry < ::GuestEntry
  end

  class Instructor < ::Instructor
    include ActiveModelUtilities

    # XXX: this is to pick up `Person` from the current scope.
    belongs_to :person, :class_name => :Person,
                        :inverse_of => :instructor

    include ControllerAware

    def self.controller_class
      InstructorsController
    end
  end

  class LessonInstructor < ::LessonInstructor
  end

  class LessonSupervision < ::LessonSupervision
    include ActiveModelUtilities

    has_many :instructors, :class_name => :Instructor,
                           :through    => :lesson_instructors

    include ControllerAware

    def self.controller_class
      LessonSupervisionsController
    end
  end

  class Member < ::Member
    include ActiveModelUtilities

    # XXX: this is to pick up `Person` from the current scope.
    belongs_to :person, :class_name => :Person,
                        :inverse_of => :member

    include ControllerAware

    def self.controller_class
      MembersController
    end
  end

  class MemberEntry < ::MemberEntry
  end

  class MemberMembership < ::MemberMembership
  end

  class MemberMessage < ::MemberMessage
  end

  class MemberShortHistory < ::MemberShortHistory
  end

  class Membership < ::Membership
    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      MembershipsController
    end

    private

      def common_options_for_urls
        super.merge(:activity_period_id => activity_period_id,
                    :membership_type_id => membership_type_id)
      end

  end

  class MembershipPurchase < ::MembershipPurchase
    include ActiveModelUtilities
  end

  class MembershipType < ::MembershipType
    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      MembershipTypesController
    end
  end

  class Payment < ::Payment
  end

  class Person < ::Person
    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      PeopleController
    end
  end

  class PersonalStatement < ::PersonalStatement
    include ActiveModelUtilities
  end

  class RevenueAccount < ::RevenueAccount
    include ActiveModelUtilities
  end

  class SecretaryNote < ::SecretaryNote
  end

  class TicketBook < ::TicketBook
    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      TicketBooksController
    end

    private

      def common_options_for_urls
        super.merge(:membership_id => membership_id)
      end

  end

  class TicketsPurchase < ::TicketsPurchase
    include ActiveModelUtilities
  end

  class WeeklyEvent < ::WeeklyEvent
    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      WeeklyEventsController
    end
  end

  class WeeklyEventSuspension < ::WeeklyEventSuspension
    include ActiveModelUtilities
  end

  # Active Model:
  class Guest < ::Guest
    include ActiveModelUtilities
  end
end
