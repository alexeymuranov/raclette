## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'
require 'app_parsers/time_duration_parser'
require 'app_validations/event'

class Event < ActiveRecord::Base
  include Filtering
  include Sorting
  self.default_sorting_column = :date
  include TimeDurationParser

  include AbstractSmarterModel

  attr_readonly :id, :event_type, :lesson, :weekly

  # Associations:
  has_many :event_entry_reservations, :dependent  => :nullify,
                                      :inverse_of => :event

  has_many :event_entries, :dependent  => :nullify,
                           :inverse_of => :event

  has_many :cashiers, :class_name => :EventCashier,
                      :dependent  => :nullify,
                      :inverse_of => :event

  belongs_to :address, :inverse_of => :events

  belongs_to :weekly_event, :inverse_of => :events

  belongs_to :lesson_supervision, :inverse_of => :events

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
  #               :length    => { :maximum => 8 }, # may allow to use AM/PM
  #               :format    => /\A\d{1,2}[:h]\d{2}?\z/,
  #               :allow_nil => true

  validates :duration, :inclusion => 5.minutes..1.day,
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
  before_save :fix_time_values__strip_date
  before_save :calculate_duration

  # Scopes:
  scope :default_order, order('date DESC, end_time DESC, start_time DESC')

  # Public class methods

  def self.sql_for_attributes  # Extends the one from AbstractSmarterModel
    unless @sql_for_attributes
      super

      long_title_sql = "(#{super[:date]} || ': ' || "\
                       "#{super[:title]})"

      @sql_for_attributes.merge!(:long_title => long_title_sql)
    end
    @sql_for_attributes
  end

  def self.attribute_db_types  # Extends the one from AbstractSmarterModel
    unless @attribute_db_types
      super

      [:long_title].each do |attr|
        @attribute_db_types[attr] = :virtual_string
      end
    end
    @attribute_db_types
  end

  # Public instance methods

  def initialize(*attributes)
    if attributes[0].is_a?(WeeklyEvent)
      super()
      weekly_event = attributes[0]
      event_date = attributes[1]
      if event_date
        if event_date.wday != weekly_event.week_day
          raise 'The given date does not match the week day '\
                'of the given weekly event'
        else
          date = event_date
        end
      end
      self.weekly = true
      [ :event_type, :title, :lesson,
        :start_time, :end_time, :duration,
        :location, :address,
        :lesson_supervision, :entry_fee_tickets
      ].each do |attr_name|
        send "#{attr_name}=", weekly_event.public_send(attr_name)
      end
    else
      super # NOTE: equivalent to super(*attributes)
    end
  end

  # Non-SQL virtual attributes

  def non_sql_long_title
    long_title = "#{ date } : #{ title }"
    if lesson_supervision && !lesson_supervision.unique_names.blank?
      long_title << " (#{ lesson_supervision.unique_names })"
    end
    long_title
  end

  # Private instance methods
  private

    def fix_time_values__strip_date # NOTE: only nullifies the date
      self.start_time = start_time.change(:year => 0, :month => 1, :day => 1)
      self.end_time = end_time.change(:year => 0, :month => 1, :day => 1)
      # self.start_time = start_time - start_time.beginning_of_day
      # self.end_time = end_time - end_time.beginning_of_day
    end

    def calculate_duration
      self.duration = end_time - start_time
      self.duration += 1.day if duration < 1.day
      # Workaround:
      self.duration = Time.gm(0,1,1,0,0,0) + duration
     end

end
# == Schema Information
#
# Table name: events
#
#  id                    :integer         not null, primary key
#  event_type            :string(32)      not null
#  title                 :string(64)
#  locked                :boolean         default(FALSE), not null
#  lesson                :boolean         not null
#  date                  :date
#  start_time            :string(8)
#  duration              :integer(2)
#  end_time              :string(8)
#  location              :string(64)
#  address_id            :integer
#  weekly                :boolean         default(FALSE), not null
#  weekly_event_id       :integer
#  supervisors           :string(255)
#  lesson_supervision_id :integer
#  entry_fee_tickets     :integer(1)
#  member_entry_fee      :decimal(3, 1)
#  couple_entry_fee      :decimal(3, 1)
#  common_entry_fee      :decimal(3, 1)
#  over                  :boolean         default(FALSE), not null
#  reservations_count    :integer(2)      default(0)
#  entries_count         :integer(2)      default(0)
#  member_entries_count  :integer(2)      default(0)
#  tickets_collected     :integer(2)      default(0)
#  entry_fees_collected  :decimal(6, 1)   default(0.0)
#  description           :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

