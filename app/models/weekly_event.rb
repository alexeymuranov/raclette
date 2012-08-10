## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'
require 'app_active_record_extensions/pseudo_columns'
require 'app_parsers/time_duration_parser'
require 'app_validations/weekly_event'

class WeeklyEvent < ActiveRecord::Base
  include Filtering
  include Sorting
  include TimeDurationParser

  include PseudoColumns
  include AbstractHumanizedModel

  attr_readonly :id, :event_type, :lesson, :start_on

  # Associations:
  has_many :weekly_event_suspensions, :dependent  => :destroy,
                                      :inverse_of => :weekly_event

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :weekly_event

  belongs_to :lesson_supervision, :inverse_of => :weekly_events

  belongs_to :address, :inverse_of => :weekly_events

  # Validations:
  validates_with WeeklyEventValidator

  validates :event_type, :title, :start_on, :week_day,
                :presence => true

  validates :event_type, :length    => { :maximum => 32 },
                         :inclusion => %w[ Cours
                                           Atelier
                                           Practica
                                           SoiréeSpécial
                                           Initiation ]

  validates :title, :length    => { :maximum => 64 },
                    :allow_nil => true

  validates :week_day, :inclusion => 0..6

  # validates :start_time, :end_time,
  #               :length    => { :maximum => 8 }, # may allow to use AM/PM
  #               :format    => /\A\d{1,2}[:h]\d{2}?\z/,
  #               :allow_nil => true

  validates :duration_minutes, :inclusion => 5..(24*60),
                               :allow_nil => true

  validates :location, :length    => { :maximum => 64 },
                       :allow_nil => true

  validates :entry_fee_tickets, :inclusion => 0..100,
                                :allow_nil => true

  validates :description, :length    => { :maximum => 255 },
                          :allow_nil => true

  validates :start_on, :end_on,
            :uniqueness => { :scope => :title }

  # Callbacks:

  # Workaround, Rails does not treat time columns well:
  before_save :fix_time_values__strip_date,
              :calculate_duration,
              :fix_start_and_end_dates

  # Scopes:
  scope :default_order, order('end_on DESC, start_on DESC')
  scope :not_over, where(:over => false)

  # Public instance methods

  def build_events
    fix_start_and_end_dates
    (start_on..end_on).step(7) do |date|
      events.build(:date => date).set_attributes_from_weekly_event
    end
  end

  # Non-SQL virtual attributes
  def virtual_long_title
    long_title = "#{ I18n.t('date.day_names')[week_day].capitalize }"\
                 " : #{ title }"
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
      duration = end_time - start_time # NOTE: duration in seconds
      duration += 1.day if duration < 1.day
      self.duration_minutes = (duration / 1.minute).to_i
    end

    def fix_start_and_end_dates
      self.start_on += (week_day    - start_on.wday) % 7
      self.end_on   -= (end_on.wday - week_day     ) % 7
    end

end
# == Schema Information
#
# Table name: weekly_events
#
#  id                    :integer         not null, primary key
#  event_type            :string(32)      not null
#  title                 :string(64)      not null
#  lesson                :boolean         not null
#  week_day              :integer(1)      not null
#  start_time            :string(8)
#  duration_minutes      :integer(2)      default(60)
#  end_time              :string(8)
#  start_on              :date            not null
#  end_on                :date
#  location              :string(64)
#  address_id            :integer
#  lesson_supervision_id :integer
#  entry_fee_tickets     :integer(1)
#  over                  :boolean         default(FALSE), not null
#  description           :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

