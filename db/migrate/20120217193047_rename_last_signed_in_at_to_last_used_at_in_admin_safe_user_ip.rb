class RenameLastSignedInAtToLastUsedAtInAdminSafeUserIp < ActiveRecord::Migration
  def up
    # This index name causes a temporary index created during migration to
    # have the name longer than 64 characters.
    remove_index :admin_safe_user_ips, [ :user_id, :known_ip_id ]
    rename_column 'admin_safe_user_ips', 'last_signed_in_at', 'last_used_at'
    add_index :admin_safe_user_ips, [ :user_id, :known_ip_id ],
                  :unique => true
  end

  def down
    # This index name causes a temporary index created during migration to
    # have the name longer than 64 characters.
    remove_index :admin_safe_user_ips, [ :user_id, :known_ip_id ]
    rename_column 'admin_safe_user_ips', 'last_used_at', 'last_signed_in_at'
    add_index :admin_safe_user_ips, [ :user_id, :known_ip_id ],
                  :unique => true
  end
end
