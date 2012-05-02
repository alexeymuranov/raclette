module TimeDurationParser
  module_function
    def parse_time_duration_to_minutes(relative_time_as_string)
      if relative_time_as_string =~ /\A\d{1,2}[:h]\d{2}?\z/
        hours = relative_time_as_string.slice(/(?<=\A)\d{1,2}(?=[:h])/).to_i
        minutes = relative_time_as_string.slice(/(?<=[:h])\d{2}?(?=\z)/).to_i
        60*hours + minutes
      end
    end

end
