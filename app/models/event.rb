## encoding: UTF-8

require 'app_active_record_extensions/pseudo_columns'
require 'app_validations/event'
require 'ruby-duration'

class Event < ActiveRecord::Base
  include PseudoColumns
  include AbstractHumanizedModel

  attr_readonly :id, :event_type, :lesson, :weekly

  # Associations:
  def self.init_associations
    belongs_to :address, :inverse_of => :events

    belongs_to :weekly_event, :inverse_of => :events

    belongs_to :lesson_supervision, :inverse_of => :events

    has_many :event_entry_reservations, :dependent  => :nullify,
                                        :inverse_of => :event

    has_many :event_entries, :dependent  => :destroy,
                             :inverse_of => :event

    has_many :participants, :through => :event_entries,
                            :source  => :person

    has_many :participant_members, :through => :participants,
                                   :source  => :member

    has_many :cashiers, :class_name => :EventCashier,
                        :dependent  => :nullify,
                        :inverse_of => :event
  end

  init_associations

  # Validations:
  validates_with EventValidator

  validates :event_type, :presence => true

  validates :event_type, :length    => { :maximum => 32 },
                         :inclusion => %w[ Cours
                                           Atelier
                                           Practica
                                           SoiréeSpécial
                                           Initiation ]

  validates :title, :location,
            :length    => { :maximum => 64 },
            :allow_nil => true

  # validates :start_time, :end_time,
  #           :length    => { :maximum => 8 }, # may allow to use AM/PM
  #           :format    => /\A\d{1,2}[:h]\d{2}?\z/,
  #           :allow_nil => true

  validates :duration_minutes, :inclusion => 5..(24*60),
                               :allow_nil => true

  validates :supervisors, :length    => { :maximum => 255 },
                          :allow_nil => true

  validates :entry_fee_tickets, :inclusion => 0..100,
                                :allow_nil => true

  validates :member_entry_fee, :couple_entry_fee, :common_entry_fee,
            :numericality => { :greater_than_or_equal_to => 0 },
            :allow_nil    => true

  validates :entries_count, :member_entries_count,
            :inclusion => 0..10000,
            :allow_nil => true

  validates :tickets_collected,
            :numericality => { :greater_than_or_equal_to => 0 },
            :allow_nil    => true

  validates :entry_fees_collected,
            :numericality => { :greater_than_or_equal_to => 0 },
            :allow_nil    => true

  validates :description, :length    => { :maximum => 255 },
                          :allow_nil => true

  # Callbacks:

  # Workaround, Rails does not treat time columns well:
  # before_validation :fix_time_values__strip_date, :calculate_duration
  before_validation :calculate_duration

  # Scopes:
  scope :default_order, lambda {
    order("#{ table_name }.date DESC, "\
          "#{ table_name }.end_time DESC, "\
          "#{ table_name }.start_time DESC")
  }
  scope :locked, lambda { where(:locked => true) }
  scope :unlocked, lambda { where(:locked => false) }
  scope :past_seven_days, lambda {
    today = Date.today
    where(:date => (today - 1.week)..today)
  }

  # Pseudo columns
  long_title_sql = "(#{ sql_for_column(:date) } || ': ' || #{ sql_for_column(:title) })"

  add_pseudo_columns :long_title => long_title_sql

  add_pseudo_column_db_types :long_title => :string

  # Public class methods

  def self.a_current
    where(:date => Date.today).
      where("#{ table_name }.start_time <= ?", Time.now.strftime("%T")).
      default_order.first
  end

  # Public instance methods

  def set_attributes_from_weekly_event
    common_attribute_names = [ :event_type, :title, :lesson,
                               :start_time, :end_time, :duration_minutes,
                               :location, :address,
                               :lesson_supervision, :entry_fee_tickets ]
    if weekly_event
      date = nil if date && date.wday != weekly_event.week_day

      common_attribute_names.each do |attr_name|
        send "#{ attr_name }=", weekly_event.public_send(attr_name)
      end
      self.weekly = true
    else
      common_attribute_names.each do |attr_name|
        send "#{ attr_name }=", nil
      end
      self.weekly = false
    end
    self
  end

  def initialize(*attributes)
    if attributes[0].is_a?(WeeklyEvent)
      super()
      self.weekly_event = attributes[0]
      self.date = attributes[1]
      set_attributes_from_weekly_event
    else
      super # NOTE: equivalent to super(*attributes)
    end
  end

  # Non-SQL virtual attributes

  def virtual_long_title
    long_title = "#{ date } : #{ title }"
    if lesson_supervision && !lesson_supervision.unique_names.blank?
      long_title << " (#{ lesson_supervision.unique_names })"
    end
    long_title
  end

  # Complex associations
  def member_participants
    participants.merge(Person.members)
  end

  def non_member_participants
    participants.merge(Person.non_members)
  end

  # Transactions
  def create_anonymous_entry(fee_payed  = common_entry_fee,
                             entry_type = 'GuestEntry')
    event_entry_attributes = { :participant_entry_type => entry_type }
    if fee_payed && fee_payed > 0
      payment_attributes = { :amount => fee_payed,
                             :date   => date }
      event_entry_attributes[:payment_attributes] = payment_attributes
    end
    event_entries.create(event_entry_attributes)
  end

  # Private instance methods
  private

    def fix_time_values__strip_date # NOTE: only nullifies the date
      self.start_time &&= start_time.change(:year => 0, :month => 1, :day => 1)
      self.end_time   &&= end_time.change(:year => 0, :month => 1, :day => 1)
    end

    def calculate_duration
      if start_time && end_time
        s_t = start_time.change(:year => 0, :month => 1, :day => 1)
        e_t = end_time.change(:year => 0, :month => 1, :day => 1)
        duration = e_t - s_t # NOTE: duration in seconds
        duration += 1.day if duration < 0
        self.duration_minutes = (duration / 1.minute).to_i
      else
        duration = nil
      end
    end

end

# == Schema Information
#
# Table name: events
#
#  id                    :integer          not null, primary key
#  event_type            :string(32)       not null
#  title                 :string(64)
#  locked                :boolean          default(FALSE), not null
#  lesson                :boolean          not null
#  date                  :date
#  start_time            :time(8)
#  end_time              :time(8)
#  location              :string(64)
#  address_id            :integer
#  weekly                :boolean          default(FALSE), not null
#  weekly_event_id       :integer
#  supervisors           :string(255)
#  lesson_supervision_id :integer
#  entry_fee_tickets     :integer
#  member_entry_fee      :decimal(3, 1)
#  couple_entry_fee      :decimal(3, 1)
#  common_entry_fee      :decimal(3, 1)
#  over                  :boolean          default(FALSE), not null
#  reservations_count    :integer          default(0)
#  entries_count         :integer          default(0)
#  member_entries_count  :integer          default(0)
#  tickets_collected     :integer          default(0)
#  entry_fees_collected  :decimal(6, 1)    default(0.0)
#  description           :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  duration_minutes      :integer
#

