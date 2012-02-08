module RespondingPaginated
  def to_html
    if get? && resource.is_a?(ActiveRecord::Relation)
      instance_variable_set "@#{controller.controller_name}", resource
      paginate_resource
    end
    super
  end
end
