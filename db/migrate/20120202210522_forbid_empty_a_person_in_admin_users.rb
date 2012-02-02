class ForbidEmptyAPersonInAdminUsers < ActiveRecord::Migration
  def up
    change_column :admin_users, :a_person, :boolean, :null => false
  end

  def down
    change_column :admin_users, :a_person, :boolean, :null => true
  end
end
