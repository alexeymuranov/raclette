class Admin::IntegratedUser < Admin::User  # NOTE: not sure if this is useful
  def self.controller_path
    Admin::UsersController.controller_path
  end
end
