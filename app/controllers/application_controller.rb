## encoding: UTF-8

require 'set'  # to be able to use Set
require 'csv'  # to render CSV
require 'monkey_patches/action_controller'
require 'app_utilities/active_model_utilities'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper
  include SessionsHelper

  before_filter :require_login
  before_filter :set_locale

  ActionController.add_renderer :csv do |obj, options| # FIXME:WIP
    # filename = options[:filename] || 'data'
    # str = obj.respond_to?(:to_csv) ? obj.to_csv : obj.to_s
    # send_data str, :type => Mime::CSV,
    #   :disposition => "attachment; filename=#{filename}.csv"
    self.content_type ||= Mime::CSV
    klass = obj.klass
    csv = csv_from_collection(obj, options[:attributes],
                                   options[:column_headers])
    filename = options[:filename] || "#{klass.model_name.human.pluralize}"\
      " #{Time.now.in_time_zone.strftime('%Y-%m-%d %k_%M')}.csv"
    self.response_body = csv
    send_data csv, :filename     => filename,
                   :content_type => "#{Mime::CSV}; charset=utf-8",
                   :disposition  => 'inline'
  end

  ActionController.add_renderer :ms_excel_2003_xml do |obj, options| # FIXME:WIP
    self.content_type ||= Mime::MS_EXCEL_2003_XML
    klass = obj.klass
    if klass < AbstractSmarterModel
      column_types = klass.attribute_db_types
    else
      column_types = {}
      attributes.each do |attr|
        column_types[attr] = klass.columns_hash[attr.to_s].type
      end
    end
    ms_excel_2003_xml = render_to_string(
      :template    => 'shared/index',
      :locals      => { :models         => obj,
                        :attributes     => options[:attributes],
                        :column_types   => column_types,
                        :column_headers => options[:column_headers] })
    filename = options[:filename] || "#{klass.model_name.human.pluralize}"\
      " #{Time.now.in_time_zone.strftime('%Y-%m-%d %k_%M')}.excel2003.xml"
    send_data ms_excel_2003_xml,
              :filename     => filename,
              :content_type => "#{Mime::MS_EXCEL_2003_XML}; charset=utf-8",
              :disposition  => 'inline'
  end

  module KnowingYourController  # NOTE: does not seem very useful
    def included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      attr_accessor :controller_path
    end

    def controller_path
      self.class.controller_path
    end
  end

  class KnownIPResource < Admin::KnownIP
    include ActiveModelUtilities
    include KnowingYourController

    # Override class name of the associated model:
    has_many :safe_users, :class_name => :UserResource,
                          :through    => :safe_user_ips,
                          :source     => :user

    def self.controller_path
      @controller_path ||= Admin::KnownIPsController.controller_path
    end
  end

  class UserResource < Admin::User
    include ActiveModelUtilities
    include KnowingYourController

    has_many :safe_ips, :class_name => :KnownIPResource,
                        :through    => :safe_user_ips,
                        :source     => :known_ip

    def self.controller_path
      @controller_path ||= Admin::UsersController.controller_path
    end
  end

  class EventResource < Event
    include ActiveModelUtilities
    include KnowingYourController

    def self.controller_path
      @controller_path ||= EventsController.controller_path
    end
  end

  class GuestResource < Guest
    include ActiveModelUtilities
  end

  class InstructorResource < Instructor
    include ActiveModelUtilities
    include KnowingYourController

    # Override association class:
    belongs_to :person, :class_name => :PersonResource,
                        :inverse_of => :instructor

    def self.controller_path
      @controller_path ||= InstructorsController.controller_path
    end
  end

  class MemberResource < Member
    include ActiveModelUtilities
    include KnowingYourController

    # Override association class:
    belongs_to :person, :class_name => :PersonResource,
                        :inverse_of => :member

    def self.controller_path
      @controller_path ||= MembersController.controller_path
    end
  end

  class PersonResource < Person
    include ActiveModelUtilities
    include KnowingYourController
  end

  private

    def set_locale  # before_filter
      # if params[:locale] is nil, then I18n.default_locale will be used
      I18n.locale = params[:locale]
      @locale = I18n.locale
    end

    def render_ms_excel_2003_xml_for_download(scoped_collection,
                                              attributes,
                                              column_headers,
                                              filename=nil)
      klass = scoped_collection.klass
      if klass < AbstractSmarterModel
        column_types = klass.attribute_db_types
      else
        column_types = {}
        attributes.each do |attr|
          column_types[attr] = klass.columns_hash[attr.to_s].type
        end
      end
      filename ||= "#{klass.model_name.human.pluralize}"\
                   " #{Time.now.in_time_zone.strftime('%Y-%m-%d %k_%M')}"\
                   ".excel2003.xml"
      send_data render_to_string(
          :template => 'shared/index',
          :locals   =>
              { :models         => scoped_collection,
                :attributes     => attributes,
                :column_types   => column_types,
                :column_headers => column_headers }),
          :filename     => filename,
          :content_type => "#{Mime::MS_EXCEL_2003_XML}; charset=utf-8",
          :disposition  => 'inline'
    end

    def render_csv_for_download(models, attributes, column_headers, filename=nil)
      send_data csv_from_collection(models, attributes, column_headers),
                :filename     => filename,
                :content_type => "#{Mime::CSV}; charset=utf-8",
                :disposition  => 'inline'
    end

    def csv_from_collection(models, attributes, column_headers)
      CSV.generate(:col_sep       => ';',
                   :row_sep       => "\r\n",
                   :encoding      => 'utf-8') do |csv|
        csv << attributes.map { |attr| column_headers[attr] } << []
        models.each do |model|
          csv << attributes.map { |attr| model.public_send(attr).to_s }
        end
      end
    end

    def paginate(models, options={})
      per_page = options[:per_page] || params[:per_page]
      per_page = per_page ? per_page.to_i : 25
      per_page = 1000 if per_page.to_i > 1000
      page = options[:page] || params[:page]
      page = page ? page.to_i : 1
      models.page(page).per(per_page)
    end

    def approximate_time
      @approximate_time ||= Time.now
    end

end
