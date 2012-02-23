## encoding: UTF-8

require 'set'
require 'app_utilities/active_model_utilities'

module Accessors
  module ControllerAware
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def controller_class  # To be redefined in classes
        "#{base_class.name.pluralize}Controller".constantize
      end

      def controller_path
        controller_class.controller_path
      end
    end

    def controller_path
      self.class.controller_path
    end
  end

  # Active Record:
  class KnownIP < ::Admin::KnownIP
    include ActiveModelUtilities

    # attr_accessible( :ip,
                     # :description,
                     # :as => :admin )

    # XXX: this is to pick up `User` from the current scope.
    # TODO:understand what this actually does and why it is needed.
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

    # attr_accessible( :username,
                     # :full_name,
                     # :a_person,
                     # :email,
                     # :account_deactivated,
                     # :admin,
                     # :manager,
                     # :secretary,
                     # :comments,
                     # :safe_ip_ids,                # association attribute
                     # :person,                     # association attribute
                     # :password,                   # virtual attribute
                     # :password_confirmation,      # virtual attribute
                     # :new_password,               # virtual attribute
                     # :new_password_confirmation,  # virtual attribute
                     # :as => :admin )

    # XXX: this is to pick up `KnownIP` from the current scope.
    # TODO:understand what this actually does and why it is needed.
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

    # attr_accessible( # :id,
                     # :unique_title,
                     # :start_date,
                     # :duration_months,
                     # :end_date,
                     # :over,
                     # :description
                   # )

    include ControllerAware

    def self.controller_class
      ActivityPeriodsController
    end
  end

  class Address < ::Address
    include ActiveModelUtilities

    # attr_accessible( # :id,
                     # :names,
                     # :address_type,
                     # :country,
                     # :city,
                     # :post_code,
                     # :street_address
                   # )
  end

  class ApplicationJournalRecord < ::ApplicationJournalRecord
    # attr_accessible( # :id,
                     # :action,
                     # :username,
                     # :user_id,
                     # :ip,
                     # :something_type,
                     # :something_id,
                     # :details,
                     # :generated_at
                   # )
  end

  class CommitteeMembership < ::CommitteeMembership
    # attr_accessible( # :id,
                     # :person_id,
                     # :function,
                     # :start_date,
                     # :end_date,
                     # :quit,
                     # :comment
                   # )
  end

  class Event < ::Event
    include ActiveModelUtilities

    # attr_accessible( # :id,
                     # :event_type,
                     # :title,
                     # :locked,
                     # :lesson,
                     # :date,
                     # :start_time,
                     # :duration_minutes,
                     # :end_time,
                     # :location,
                     # :address_id,
                     # :weekly,
                     # :weekly_event_id,
                     # :supervisors,
                     # :lesson_supervision_id,
                     # :entry_fee_tickets,
                     # :member_entry_fee,
                     # :couple_entry_fee,
                     # :common_entry_fee,
                     # :over,
                     # :reservations_count,
                     # :entries_count,
                     # :member_entries_count,
                     # :tickets_collected,
                     # :entry_fees_collected,
                     # :description
                   # )

    include ControllerAware

    def self.controller_class
      EventsController
    end
  end

  class EventCashier < ::EventCashier
    # attr_accessible( # :id,
                     # :event_id,
                     # :name,
                     # :person_id,
                     # :started_at,
                     # :finished_at
                   # )
  end

  class EventEntry < ::EventEntry
    # attr_accessible( # :id,
                     # :participant_entry_type,
                     # :participant_entry_id,
                     # :event_title,
                     # :date,
                     # :event_id,
                     # :person_id
                   # )
  end

  class GuestEntry < ::GuestEntry
    # attr_accessible( # :id,
                     # :first_name,
                     # :last_name,
                     # :inviting_member_id,
                     # :previous_entry_id,
                     # :toward_membership_purchase_id,
                     # :email,
                     # :phone,
                     # :note
                   # )
  end

  class Instructor < ::Instructor
    include ActiveModelUtilities

    # attr_accessible( # :id,
                     # :person_id,
                     # :presentation,
                     # :photo,
                     # :employed_from,
                     # :employed_until
                   # )

    # XXX: this is to pick up `Person` from the current scope.
    # TODO:understand what this actually does and why it is needed.
    belongs_to :person, :class_name => :Person,
                        :inverse_of => :instructor

    include ControllerAware

    def self.controller_class
      InstructorsController
    end
  end

  class LessonInstructor < ::LessonInstructor
    # attr_accessible( # :id,
                     # :lesson_supervision_id,
                     # :instructor_id,
                     # :invited,
                     # :volunteer,
                     # :assistant
                   # )
  end

  class LessonSupervision < ::LessonSupervision
    include ActiveModelUtilities

    # attr_accessible( # :id,
                     # :unique_names,
                     # :instructors_count,
                     # :comment
                   # )
  end

  class Member < ::Member
    include ActiveModelUtilities

    # attr_accessible( :been_member_by,
                     # :free_tickets_count,
                     # :last_name,         # delegated attribute
                     # :first_name,        # delegated attribute
                     # :name_title,        # delegated attribute
                     # :nickname_or_other, # delegated attribute
                     # :birthyear,         # delegated attribute
                     # :email,             # delegated attribute
                     # :mobile_phone,      # delegated attribute
                     # :home_phone,        # delegated attribute
                     # :work_phone,        # delegated attribute
                     # :personal_phone,    # delegated attribute
                     # :primary_address,   # delegated attribute
                     # :person_attributes, # association attribute
                     # :as => [:secretary, :manager] )

    # XXX: this is to pick up `Person` from the current scope.
    # TODO:understand what this actually does and why it is needed.
    belongs_to :person, :class_name => :Person,
                        :inverse_of => :member

    include ControllerAware

    def self.controller_class
      MembersController
    end
  end

  class MemberEntry < ::MemberEntry
    # attr_accessible( # :id,
                     # :member_id,
                     # :guests_invited,
                     # :tickets_used
                   # )
  end

  class MemberMembership < ::MemberMembership
    # attr_accessible( # :id,
                     # :member_id,
                     # :membership_id,
                     # :obtained_on
                   # )
  end

  class MemberMessage < ::MemberMessage
    # attr_accessible( # :id,
                     # :member_id,
                     # :content,
                     # :created_on
                   # )
  end

  class MemberShortHistory < ::MemberShortHistory
    # attr_accessible( # :id,
                     # :member_id,
                     # :last_active_membership_expiration_date,
                     # :prev_membership_expiration_date,
                     # :prev_membership_type,
                     # :prev_membership_duration_months
                   # )
  end

  class Membership < ::Membership
    # attr_accessible( # :id,
                     # :membership_type_id,
                     # :activity_period_id,
                     # :initial_price,
                     # :current_price,
                     # :tickets_count_limit,
                     # :members_count
                   # )
  end

  class MembershipPurchase < ::MembershipPurchase
    # attr_accessible( # :id,
                     # :member_id,
                     # :membership_type,
                     # :membership_expiration_date,
                     # :membership_id,
                     # :purchase_date
                   # )
  end

  class MembershipType < ::MembershipType
    include ActiveModelUtilities

    # attr_accessible( # :id,
                     # :unique_title,
                     # :active,
                     # :reduced,
                     # :unlimited,
                     # :duration_months,
                     # :description
                   # )

    include ControllerAware

    def self.controller_class
      ActivityPeriodsController
    end
  end

  class Payment < ::Payment
    # attr_accessible( # :id,
                     # :payable_type,
                     # :payable_id,
                     # :date,
                     # :amount,
                     # :method,
                     # :revenue_account_id,
                     # :payer_person_id,
                     # :cancelled_and_reimbursed,
                     # :cancelled_on,
                     # :note
                   # )
  end

  class Person < ::Person
    include ActiveModelUtilities

    # attr_accessible( :last_name,
                     # :first_name,
                     # :name_title,
                     # :nickname_or_other,
                     # :email,
                     # :as => [:secretary, :manager] )

    include ControllerAware

    def self.controller_class
      PeopleController
    end
  end

  class PersonalStatement < ::PersonalStatement
    include ActiveModelUtilities

    # attr_accessible( # :id,
                     # :person_id,
                     # :birthday
                     # :accept_email_announcements,
                     # :volunteer,
                     # :volunteer_as,
                     # :preferred_language,
                     # :occupation,
                     # :remark
                   # )
  end

  class RevenueAccount < ::RevenueAccount
    include ActiveModelUtilities

    # attr_accessible( # :id,
                     # :unique_title,
                     # :locked,
                     # :activity_period_id,
                     # :opened_on,
                     # :closed_on,
                     # :main,
                     # :amount,
                     # :amount_updated_on,
                     # :description
                   # )
  end

  class SecretaryNote < ::SecretaryNote
    # attr_accessible( # :id,
                     # :note_type,
                     # :something_type,
                     # :something_id,
                     # :created_on
                     # :message,
                     # :message_updated_at
                   # )
  end

  class TicketBook < ::TicketBook
    include ActiveModelUtilities

    # attr_accessible( # :id,
                     # :membership_type_id,
                     # :tickets_number,
                     # :price
                   # )

    include ControllerAware

    def self.controller_class
      TicketBooksController
    end
  end

  class TicketsPurchase < ::TicketsPurchase
    # attr_accessible( # :id,
                     # :member_id,
                     # :ticket_book_id,
                     # :tickets_number,
                     # :purchase_date
                   # )
  end

  class WeeklyEvent < ::WeeklyEvent
    include ActiveModelUtilities

    # attr_accessible( # :id,
                     # :event_type,
                     # :title,
                     # :lesson,
                     # :week_day,
                     # :start_time,
                     # :duration_minutes,
                     # :end_time,
                     # :start_on,
                     # :end_on,
                     # :location,
                     # :address_id,
                     # :lesson_supervision_id,
                     # :entry_fee_tickets,
                     # :over,
                     # :description
                   # )

    include ControllerAware

    def self.controller_class
      WeeklyEventsController
    end
  end

  class WeeklyEventSuspension < ::WeeklyEventSuspension
    include ActiveModelUtilities

    # attr_accessible( # :id,
                     # :weekly_event_id,
                     # :suspend_from,
                     # :suspend_until,
                     # :explanation
                   # )
  end

  # Active Model:
  class Guest < ::Guest
    include ActiveModelUtilities
  end
end
