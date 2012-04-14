require 'app_sql_queries/simple_filter'

module Filtering
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    attr_reader :last_filter_values
    def filter(scoped_collection, filter_params, filtering_attributes)
      sfilter = SimpleFilter.new
      if filter_params
        sfilter.set_filtering_values_from_human_hash(filter_params, self)
        sfilter.filtering_attributes = filtering_attributes
        scoped_collection = sfilter.do_filter(scoped_collection)
      end
      @last_filter_values = sfilter.filtering_values
      scoped_collection
    end
  end
end
