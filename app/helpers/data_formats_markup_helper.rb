## encoding: UTF-8

module DataFormatsMarkupHelper

  def boolean_to_yes_no(bool)
    bool ? t(:yes) : t(:no)
  end

  def boolean_to_picto(bool, size=1)
    bool ? yes_pictogram(size) : t(:no)
  end
end
