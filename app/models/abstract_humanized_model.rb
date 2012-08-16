module AbstractHumanizedModel
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def human_column_headers
      @human_column_headers ||= Hash.new { |hash, key|
        name = human_attribute_name(key)
        case column_db_type(attr)
        when :boolean
          hash[key] = I18n.t('formats.attribute_name?', :attribute => name)
        else
          hash[key] = I18n.t('formats.attribute_name:', :attribute => name)
        end
      }
    end

    def human_column_header(attr)
      human_column_headers[attr]
    end
  end
end
