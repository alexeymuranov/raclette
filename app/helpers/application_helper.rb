module ApplicationHelper

  def title
    base_title = 'Raclette'
    @title.nil? ? base_title : "#{base_title} | #{@title}"
  end

  def logo
    image_tag 'raclette.png', :alt => 'raclette'
  end
end
