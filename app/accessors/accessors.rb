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
    include ControllerAware

    # attr_accessible( :ip,
                     # :description,
                     # :as => :admin )

    # XXX: this is to pick up `User` from the current scope.
    # TODO:understand what this actually does and why it is needed.
    has_many :safe_users, :class_name => :User,
                          :through    => :safe_user_ips,
                          :source     => :user

    def self.controller_class
      Admin::KnownIPsController
    end
  end

  class User < ::Admin::User
    include ActiveModelUtilities
    include ControllerAware

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

    def self.controller_class
      Admin::UsersController
    end
  end

  class Event < ::Event
    include ActiveModelUtilities
    include ControllerAware

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
      EventsController
    end
  end

  class Instructor < ::Instructor
    include ActiveModelUtilities
    include ControllerAware

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

    def self.controller_class
      InstructorsController
    end
  end

  class Member < ::Member
    include ActiveModelUtilities
    include ControllerAware

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

    def self.controller_class
      MembersController
    end
  end

  class Person < ::Person
    include ActiveModelUtilities
    include ControllerAware

    # attr_accessible( :last_name,
                     # :first_name,
                     # :name_title,
                     # :nickname_or_other,
                     # :email,
                     # :as => [:secretary, :manager] )
  end

  # Active Model:
  class Guest < ::Guest
    include ActiveModelUtilities
  end
end
