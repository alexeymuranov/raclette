module ApplicationHelper

  def title
    base_title = 'Raclette'
    @title.nil? ? base_title : "#{base_title} | #{@title}"
  end

  LOGO_PICTURE_FILE_NAMES = { :small  => 'raclette-w65.png',
                              :medium => 'raclette-w130.png',
                              :big    => 'raclette-w160.png' }

  def logo(logo_size=:medium)
    image_tag LOGO_PICTURE_FILE_NAMES[logo_size], :alt => 'raclette'
  end
end
