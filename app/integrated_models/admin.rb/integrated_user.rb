class Admin::IntegratedUser < Admin::User  # NOTE: not sure if this is useful
  def self.controller_name
    'admin/users'
  end
end