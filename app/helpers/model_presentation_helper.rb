## encoding: UTF-8

module ModelPresentationHelper

  def title_from_model_name(model)
    capitalize_first_letter_of(model.model_name.human)
  end

  def title_from_association_name(model, association)
    capitalize_first_letter_of(model.human_attribute_name(association))
  end

  def label_from_attribute_name(model, attribute, column_type = nil)
    # NOTE: it is assumed that `AttributeTypes` module is included
    # XXX: this is not true: `AttributeTypes` does not exist yet
    column_type ||= model.column_db_type(attribute)

    human_attribute_name =
      capitalize_first_letter_of(
        model.human_attribute_name(attribute))

    format_localisation_key =
      case column_type
      when :boolean
        'formats.attribute_name?'
      else
        'formats.attribute_name:'
      end

    t(format_localisation_key, :attribute => human_attribute_name)
  end

  def html_class_from_column_type(column_type)
    { :string  => 'text',
      :boolean => 'boolean',
      :integer => 'number',
      :date    => 'date',
      :text    => 'long_text' }[column_type] || column_type
  end

  def input_html_type_for_attribute(model, attribute, column_type = nil)
    # NOTE: it is assumed that `AttributeTypes` and
    # `AttributeConstraints` modules are included
    # XXX: this is not true: `AttributeTypes` and `AttributeConstraints` do not exist yet
    column_type ||= model.column_db_type(attribute)

    case column_type
    when :boolean
      :checkbox
    when :date, :time, :datetime
      column_type
    when :integer
      :number
    when :string
      case model.attribute_constraints_on(attribute)[:format]
      when :email
        :email
      when :telephone
        :tel
      else
        :text
      end
    when :text
      :text_area
    else
      :text
    end
  end
end
