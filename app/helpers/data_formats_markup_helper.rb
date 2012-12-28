## encoding: UTF-8

module DataFormatsMarkupHelper

  def boolean_to_yes_no(bool)
    bool ? t(:yes) : t(:no)
  end

  def boolean_to_picto(bool, size=1)
    bool ? yes_pictogram(size) : t(:no)
  end

  def capitalize_first_letter_of(str)
    unless str.empty?
      str = ActiveSupport::Multibyte::Chars.new(str)
      str[0] = str[0].upcase
      str.to_s
    end
  end
end
