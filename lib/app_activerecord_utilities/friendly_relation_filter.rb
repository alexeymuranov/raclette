require_relative 'simple_relation_filter'

class FriendlyRelationFilter < SimpleRelationFilter

  def set_filtering_values_from_text_hash(filtering_text_hash)

    self.filtering_values = {}

    filtering_attributes.each do |attr|

      next unless value = filtering_text_hash[attr.to_s]


      column_type = if model.include?(PseudoColumns)
                      model.column_db_type(attr)
                    else
                      model.columns_hash[column_name].type
                    end

      case column_type
      when :string
        case value
        when Set, Array
          filtering_values[attr] = value.map!(&:to_s).to_set
        else
          unless value.blank?
            filtering_values[attr] = value.sub(/\%*\z/, '%')
          end
        end

      when :boolean
        case value
        when nil
        when true, /\Ayes\z/i, /\Atrue\z/i, /\Ay\z/i, /\At\z/i, 1, '1'
          filtering_values[attr] = true
        when false, /\Ano\z/i, /\Afalse\z/i, /\An\z/i, /\Af\z/i, 0, '0'
          filtering_values[attr] = false
        end

      when :integer
        case value
        when Hash
          minimum = value[:min]
          minimum = minimum.blank? ? nil : minimum.to_i
          maximum = value[:max]
          maximum = maximum.blank? ? nil : maximum.to_i
          if minimum || maximum
            filtering_values[attr] =
              (minimum || -Float::INFINITY)..(maximum || Float::INFINITY)
          end
        when Set, Array
          filtering_values[attr] = value.map!(&:to_i).to_set
        else
          filtering_values[attr] = value.to_i
        end

      when :date
        case value
        when Hash
          start_date = value[:from] || value[:min]
          start_date = start_date.blank? ? nil : start_date.to_date
          end_date = value[:until] || value[:max]
          end_date = end_date.blank? ? nil : end_date.to_date
          if start_date || end_date
            filtering_values[attr] = {}
            filtering_values[attr][:from]  = start_date unless start_date.nil?
            filtering_values[attr][:until] = end_date   unless end_date.nil?
          end
        when Set, Array
          filtering_values[attr] = value.map!(&:to_date).to_set
        else
          filtering_values[attr] = value.to_date
        end
      end
    end
  end
end
