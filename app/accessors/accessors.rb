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

  # Active Record:
  class KnownIPResource < Admin::KnownIP
    include ActiveModelUtilities
    include KnowingYourController

    # attr_accessible( :ip,
                     # :description,
                     # :as => :admin )

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

    def self.controller_class
      @controller_class || EventsController
    end
  end

  class InstructorResource < Instructor
    include ActiveModelUtilities
    include KnowingYourController

    # attr_accessible( # :id,
                     # :person_id,
                     # :presentation,
                     # :photo,
                     # :employed_from,
                     # :employed_until
                   # )

    belongs_to :person, :class_name => :PersonResource,
                        :inverse_of => :instructor

    def self.controller_class
      @controller_class || InstructorsController
    end
  end

  class MemberResource < Member
    include ActiveModelUtilities
    include KnowingYourController

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

    belongs_to :person, :class_name => :PersonResource,
                        :inverse_of => :member

    def self.controller_class
      @controller_class || MembersController
    end
  end

  class PersonResource < Person
    include ActiveModelUtilities
    include KnowingYourController

    # attr_accessible( :last_name,
                     # :first_name,
                     # :name_title,
                     # :nickname_or_other,
                     # :email,
                     # :as => [:secretary, :manager] )
  end

  # Active Model:
  class GuestResource < Guest
    include ActiveModelUtilities
  end
end
