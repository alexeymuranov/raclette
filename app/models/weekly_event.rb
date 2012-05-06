## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'
require 'app_parsers/time_duration_parser'

class WeeklyEvent < ActiveRecord::Base
  include Filtering
  include Sorting
  include TimeDurationParser

  include AbstractSmarterModel

  attr_readonly :id, :event_type, :lesson, :start_on

  # Associations:
  has_many :weekly_event_suspensions, :dependent  => :destroy,
                                      :inverse_of => :weekly_event

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :weekly_event

  belongs_to :lesson_supervision, :inverse_of => :weekly_events

  belongs_to :address, :inverse_of => :weekly_events

  # Validations:
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

  validates :duration, :inclusion => 5.minutes..1.day,
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
  before_save :fix_time_values__strip_date
  before_save :calculate_duration

  # Scopes:
  scope :default_order, order('end_on DESC, start_on DESC')
  scope :not_over, where(:over => false)

  # Public instance methods

  # Non-SQL virtual attributes
  def non_sql_long_title
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
      self.duration = end_time - start_time
      self.duration += 1.day if duration < 1.day
      # Workaround:
      self.duration = Time.gm(0,1,1,0,0,0) + duration
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
#  duration              :integer(2)      default(60)
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

