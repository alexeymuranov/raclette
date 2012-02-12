class Admin::IntegratedKnownIP < Admin::KnownIP  # NOTE: not sure if this is useful
  def self.controller_path
    Admin::KnownIPsController.controller_path
  end
end
