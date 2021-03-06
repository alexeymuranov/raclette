## encoding: UTF-8

require 'app_active_record_extensions/pseudo_columns'

class LessonSupervision < ActiveRecord::Base
  include PseudoColumns
  include AbstractHumanizedModel

  # XXX: temporary workaround to override 'counter cache':
  # attr_readonly :id, :unique_names, :instructors_count
  attr_readonly :id, :unique_names

  # Associations:
  def self.init_associations
    has_many :lesson_instructors, :dependent  => :destroy,
                                  :inverse_of => :lesson_supervision

    has_many :instructors, :through => :lesson_instructors

    has_many :weekly_events, :dependent  => :nullify,
                             :inverse_of => :lesson_supervision

    has_many :events, :dependent  => :nullify,
                      :inverse_of => :lesson_supervision
  end

  init_associations

  # Validations:
  validates :unique_names, :instructors_count,
            :presence => true

  validates :unique_names, :length => 1..128

  validates :instructors_count, :inclusion => 1..4

  validates :comment, :length    => { :maximum => 255 },
                      :allow_nil => true

  validates :unique_names, :uniqueness => { :case_sensitive => false }

  # Scopes:
  scope :default_order, lambda {
    order("#{ table_name }.instructors_count ASC, "\
          "#{ table_name }.unique_names ASC")
  }
end

# == Schema Information
#
# Table name: lesson_supervisions
#
#  id                :integer          not null, primary key
#  unique_names      :string(128)      not null
#  instructors_count :integer          default(1), not null
#  comment           :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

