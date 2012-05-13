## encoding: UTF-8

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'

class LessonSupervision < ActiveRecord::Base
  include Filtering
  include Sorting

  include AbstractSmarterModel

  # XXX: temporary workaround to override 'counter cache':
  # attr_readonly :id, :unique_names, :instructors_count
  attr_readonly :id, :unique_names

  # Associations:
  has_many :lesson_instructors, :dependent  => :destroy,
                                :inverse_of => :lesson_supervision

  has_many :instructors, :through => :lesson_instructors

  has_many :weekly_events, :dependent  => :nullify,
                           :inverse_of => :lesson_supervision

  has_many :events, :dependent  => :nullify,
                    :inverse_of => :lesson_supervision

  # Validations:
  validates :unique_names, :instructors_count,
            :presence => true

  validates :unique_names, :length => 1..128

  validates :instructors_count, :inclusion => 1..4

  validates :comment, :length    => { :maximum => 255 },
                      :allow_nil => true

  validates :unique_names, :uniqueness => { :case_sensitive => false }

  # Scopes:
  scope :default_order, order('instructors_count ASC, unique_names ASC')
end
# == Schema Information
#
# Table name: lesson_supervisions
#
#  id                :integer         not null, primary key
#  unique_names      :string(128)     not null
#  instructors_count :integer(1)      default(1), not null
#  comment           :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

