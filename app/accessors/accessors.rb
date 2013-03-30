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
  BASIC_AR_MODELS =
    [ ::Admin::KnownIP,
      ::Admin::User,
      ::Admin::SafeUserIP,
      ::ActivityPeriod,
      ::ApplicationJournalRecord,
      ::CommitteeMembership,
      ::Event,
      ::EventCashier,
      ::EventEntry,
      ::GuestEntry,
      ::Instructor,
      ::LessonInstructor,
      ::LessonSupervision,
      ::Member,
      ::MemberEntry,
      ::MemberMembership,
      ::MemberMessage,
      ::MemberShortHistory,
      ::Membership,
      ::MembershipPurchase,
      ::MembershipType,
      ::Payment,
      ::Person,
      ::PersonalStatement,
      ::RevenueAccount,
      ::SecretaryNote,
      ::TicketBook,
      ::TicketsPurchase,
      ::WeeklyEvent,
      ::WeeklyEventSuspension ]

  MODELS = [].tap do |accessor_models|
    BASIC_AR_MODELS.each do |model|
      accessor_models << (accessor_model = Class.new(model))
      const_set(model.name.split('::').last, accessor_model)
      accessor_model.init_associations
    end
  end

  MODELS << const_set(:Guest, Class.new(::Guest))

  MODELS.each do |model|
    model.class_eval do
      include ActiveModelUtilities
    end
  end

  MODEL_CONTROLLER_CLASS_NAMES =
    { KnownIP           => 'Admin::KnownIPsController',
      User              => 'Admin::UsersController',
      SafeUserIP        => 'Admin::SafeUserIPsController',
      ActivityPeriod    => 'ActivityPeriodsController',
      Event             => 'EventsController',
      Instructor        => 'InstructorsController',
      LessonSupervision => 'LessonSupervisionsController',
      Member            => 'MembersController',
      Membership        => 'MembershipsController',
      MembershipType    => 'MembershipTypesController',
      Person            => 'PeopleController',
      TicketBook        => 'TicketBooksController',
      WeeklyEvent       => 'WeeklyEventsController' }

  MODEL_CONTROLLER_CLASS_NAMES.keys.each do |accessor_model|
    accessor_model.class_eval do
      include ControllerAware
    end

    controller_class_name = MODEL_CONTROLLER_CLASS_NAMES[accessor_model]
    accessor_model.define_singleton_method :controller_class do
      @controller_class ||= controller_class_name.constantize
    end
  end

  class Membership
    private
      def common_options_for_urls
        super.merge(:activity_period_id => activity_period_id,
                    :membership_type_id => membership_type_id)
      end

  end

  class TicketBook
    private
      def common_options_for_urls
        super.merge(:membership_id => membership_id)
      end

  end
end
