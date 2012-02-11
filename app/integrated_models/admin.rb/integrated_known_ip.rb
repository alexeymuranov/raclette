class Admin::IntegratedKnownIP < Admin::KnownIP  # NOTE: not sure if this is useful
  def self.controller_name
    'admin/known_i_ps'
  end
end