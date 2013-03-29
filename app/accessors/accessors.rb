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
    init_associations

    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      Admin::KnownIPsController
    end
  end

  class User < ::Admin::User
    init_associations

    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      Admin::UsersController
    end
  end

  class ActivityPeriod < ::ActivityPeriod
    init_associations

    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      ActivityPeriodsController
    end
  end

  class Address < ::Address
    init_associations

    include ActiveModelUtilities
  end

  class ApplicationJournalRecord < ::ApplicationJournalRecord
    init_associations
  end

  class CommitteeMembership < ::CommitteeMembership
    init_associations
  end

  class Event < ::Event
    init_associations

    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      EventsController
    end
  end

  class EventCashier < ::EventCashier
    init_associations
  end

  class EventEntry < ::EventEntry
    init_associations
  end

  class GuestEntry < ::GuestEntry
    init_associations
  end

  class Instructor < ::Instructor
    init_associations

    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      InstructorsController
    end
  end

  class LessonInstructor < ::LessonInstructor
    init_associations
  end

  class LessonSupervision < ::LessonSupervision
    init_associations

    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      LessonSupervisionsController
    end
  end

  class Member < ::Member
    init_associations

    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      MembersController
    end
  end

  class MemberEntry < ::MemberEntry
    init_associations
  end

  class MemberMembership < ::MemberMembership
  end

  class MemberMessage < ::MemberMessage
    init_associations
  end

  class MemberShortHistory < ::MemberShortHistory
    init_associations
  end

  class Membership < ::Membership
    init_associations

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
    init_associations

    include ActiveModelUtilities
  end

  class MembershipType < ::MembershipType
    init_associations

    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      MembershipTypesController
    end
  end

  class Payment < ::Payment
    init_associations
  end

  class Person < ::Person
    init_associations

    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      PeopleController
    end
  end

  class PersonalStatement < ::PersonalStatement
    init_associations

    include ActiveModelUtilities
  end

  class RevenueAccount < ::RevenueAccount
    init_associations

    include ActiveModelUtilities
  end

  class SecretaryNote < ::SecretaryNote
  end

  class TicketBook < ::TicketBook
    init_associations

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
    init_associations

    include ActiveModelUtilities
  end

  class WeeklyEvent < ::WeeklyEvent
    init_associations

    include ActiveModelUtilities

    include ControllerAware

    def self.controller_class
      WeeklyEventsController
    end
  end

  class WeeklyEventSuspension < ::WeeklyEventSuspension
    init_associations

    include ActiveModelUtilities
  end

  # Active Model:
  class Guest < ::Guest
    include ActiveModelUtilities
  end
end
