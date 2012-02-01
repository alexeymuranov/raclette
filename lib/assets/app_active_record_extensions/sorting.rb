# Class methods for ActiveRecord descendants
module Sorting # TODO
  attr_accessor :default_sorting_column, :all_sorting_columns
  attr_reader :last_sort_column, :last_sort_direction

  def sort_column(sort_params)
    if (suggested_sort_column = sort_params[:column]).blank?
      default_sorting_column
    else
      all_sorting_columns.map(&:to_s).include?(suggested_sort_column.to_s) ?
        suggested_sort_column : default_sorting_column
    end
  end

  def sort_direction(sort_params)
    sort_params[:direction] == 'DESC' ? :DESC : :ASC
  end

  def sort(scoped_collection, sort_params)
    @last_sort_column = sort_column(sort_params)
    @last_sort_direction = sort_direction(sort_params)
    scoped_collection.order("#{@last_sort_column} #{@last_sort_direction}")
  end
end