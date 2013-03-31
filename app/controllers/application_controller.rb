## encoding: UTF-8

require 'set'  # to be able to use Set
require 'app_renderers'
require 'app_activerecord_utilities/friendly_relation_filter'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper
  include SessionsHelper
  include Accessors

  before_filter :require_login
  before_filter :set_locale

  private

    def set_locale  # before_filter
      # if params[:locale] is nil, then I18n.default_locale will be used
      I18n.locale = params[:locale]
      @locale = I18n.locale
    end

    def paginate(collection, options = {})
      per_page = options[:per_page] || params[:per_page]
      per_page = per_page ? per_page.to_i : 25
      per_page = 1000 if per_page.to_i > 1000
      page = options[:page] || params[:page]
      page = page ? page.to_i : 1
      collection.page(page).per(per_page)
    end

    def do_filtering(collection_scope, values     = params[:filter],
                                       attributes = @attributes)
      if values
        @filter = FriendlyRelationFilter.new(collection_scope.klass)
        @filter.filtering_attributes = attributes
        @filter.set_filtering_values_from_text_hash(values)
        @filtering_values =
          @filter.filtering_attributes_as_simple_nested_hash
        collection_scope.merge(@filter.to_scope)
      else
        @filter = nil
        @filtering_values = nil
        collection_scope
      end
    end

end
