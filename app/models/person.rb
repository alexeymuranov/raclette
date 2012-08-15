## encoding: UTF-8

require 'app_validations/email_format'

require 'app_active_record_extensions/filtering'
require 'app_active_record_extensions/sorting'
require 'app_active_record_extensions/pseudo_columns'

class Person < ActiveRecord::Base

  include Filtering
  include Sorting
  self.default_sorting_column = :ordered_full_name

  include PseudoColumns
  include AbstractHumanizedModel

  attr_readonly :id, :last_name

  # Associations
  has_many :users, :class_name => :'Admin::User',
                   :dependent  => :nullify,
                   :inverse_of => :person

  has_one :statement, :class_name => :PersonalStatement,
                      :dependent  => :destroy,
                      :inverse_of => :person

  has_one :instructor, :dependent  => :destroy,
                       :inverse_of => :person

  has_many :committee_memberships, :dependent  => :destroy,
                                   :inverse_of => :person

  has_one :member, :dependent  => :destroy,
                   :inverse_of => :person

  has_many :payments, :foreign_key => :payer_person_id,
                      :dependent   => :nullify,
                      :inverse_of  => :payer

  has_many :event_entries, :dependent  => :destroy,
                           :inverse_of => :person

  has_many :attended_events, :through => :event_entries,
                             :source  => :event

  has_many :event_cashiers, :dependent  => :nullify,
                            :inverse_of => :person

  belongs_to :primary_address, :class_name => :Address,
                               :inverse_of => :people

  accepts_nested_attributes_for :primary_address, :statement

  # Validations
  validates :last_name, :first_name,
            :presence => true

  validates :last_name, :first_name, :nickname_or_other,
            :length => { :maximum => 32 }

  validates :name_title, :length    => { :maximum => 16 },
                         :inclusion => %w[Mme Mlle M. Ms Mrs Miss Mr],
                         :allow_nil => true

  validates :birthyear, :inclusion => 1900..2099,
                        :allow_nil => true

  validates :email, :length       => { :maximum => 255 },
                    :email_format => true,
                    :allow_nil    => true

  validates :mobile_phone, :home_phone, :work_phone,
                :length    => { :maximum => 32 },
                :allow_nil => true

  validates :nickname_or_other,
            :uniqueness => { :scope => [ :last_name, :first_name ] }

  # Pseudo columns
  full_name_sql         =  "(#{ sql_for_columns[:name_title] } || ' ' || " \
                           "#{ sql_for_columns[:first_name] } || ' ' || " \
                           "#{ sql_for_columns[:last_name] })"

  ordered_full_name_sql = "(UPPER(#{ sql_for_columns[:last_name] }) || ', ' || " \
                          "#{ sql_for_columns[:first_name] } || ', ' || " \
                          "#{ sql_for_columns[:name_title] })"

  formatted_email_sql   = "(#{ full_name_sql } || " \
                          "' <' || #{ sql_for_columns[:email] } || '>')"

  add_pseudo_columns :full_name         => full_name_sql,
                     :ordered_full_name => ordered_full_name_sql,
                     :formatted_email   => formatted_email_sql

  [:full_name, :ordered_full_name, :formatted_email].each do |attr|
    add_pseudo_column_db_types attr => :string
  end

  # Scopes
  scope :default_order, # check if this works as expected
        order("UPPER(#{ sql_for_columns[:last_name] }) ASC").
        order("UPPER(#{ sql_for_columns[:first_name] }) ASC")
        # order("UPPER(#{ sql_for_columns[:last_name] }) ASC, "\
        #       "UPPER(#{ sql_for_columns[:first_name] }) ASC")

  scope :members, joins(:member)

  scope :non_members,
        joins("LEFT JOIN members ON people.id = members.person_id").
        where("members.person_id IS NULL")

  # Public instance methods
  # Non-SQL virtual attributes
  def virtual_full_name
    [ name_title,
      first_name,
      nickname_or_other.blank? ? nil : "'#{ nickname_or_other }'",
      last_name ].reject(&:blank?).join(' ')
  end

  def virtual_personal_phone
    mobile_phone || home_phone
  end

  # Transactions
  def attend_event(event, entry_type = 'GuestEntry')
    event_entries.create(:event                  => event,
                         :participant_entry_type => entry_type)
  end
end

# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  last_name          :string(32)       not null
#  first_name         :string(32)       not null
#  name_title         :string(16)
#  nickname_or_other  :string(32)       default(""), not null
#  birthyear          :integer
#  email              :string(255)
#  mobile_phone       :string(32)
#  home_phone         :string(32)
#  work_phone         :string(32)
#  primary_address_id :integer
#  created_at         :datetime
#  updated_at         :datetime
#

