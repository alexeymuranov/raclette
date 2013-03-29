## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'
require 'app_active_record_extensions/pseudo_columns'
require 'app_validations/weekly_event'
require 'ruby-duration'

class WeeklyEvent < ActiveRecord::Base
  include Filtering
  include Sorting

  include PseudoColumns
  include AbstractHumanizedModel

  attr_readonly :id, :event_type, :lesson, :start_on

  # Associations:
  def self.init_associations
    belongs_to :lesson_supervision, :inverse_of => :weekly_events

    belongs_to :address, :inverse_of => :weekly_events

    has_many :weekly_event_suspensions, :dependent  => :destroy,
                                        :inverse_of => :weekly_event

    has_many :events, :dependent  => :nullify,
                      :inverse_of => :weekly_event
  end

  init_associations

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
  # before_validation :fix_time_values__strip_date,
  before_validation :calculate_duration,
                    :adjust_start_and_end_dates

  # Scopes:
  scope :default_order, order("#{ table_name }.end_on DESC, "\
                              "#{ table_name }.start_on DESC")
  scope :not_over, where(:over => false)

  # Public instance methods

  def build_events
    adjust_start_and_end_dates
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

    def adjust_start_and_end_dates
      self.start_on += (week_day    - start_on.wday) % 7
      self.end_on   -= (end_on.wday - week_day     ) % 7
    end

end

# == Schema Information
#
# Table name: weekly_events
#
#  id                    :integer          not null, primary key
#  event_type            :string(32)       not null
#  title                 :string(64)       not null
#  lesson                :boolean          not null
#  week_day              :integer          not null
#  start_time            :time(8)
#  end_time              :time(8)
#  start_on              :date             not null
#  end_on                :date
#  location              :string(64)
#  address_id            :integer
#  lesson_supervision_id :integer
#  entry_fee_tickets     :integer
#  over                  :boolean          default(FALSE), not null
#  description           :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  duration_minutes      :integer
#

