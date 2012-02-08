## encoding: UTF-8

module ApplicationHelper

  def title
    base_title = 'Raclette'

    controller_i18n_scope = controller.class.name\
                                      .sub(/Controller$/, '')\
                                      .gsub('::', '.').underscore
    # NOTE: there exists a protected method controller_i18n_scope in Rails::Generators::ResourceHelpers.

    @title ||= t("#{controller_i18n_scope}.#{action_name}.title")
    # NOTE: using conroller_name instead of controller_i18n_scope does not work (loses module part).

    @title.nil? ? base_title : "#{base_title} | #{@title}"
  end
end
