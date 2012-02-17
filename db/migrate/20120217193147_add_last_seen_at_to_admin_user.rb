class AddLastSeenAtToAdminUser < ActiveRecord::Migration
  def change
    add_column 'admin_users', 'last_seen_at', :datetime
  end
end
