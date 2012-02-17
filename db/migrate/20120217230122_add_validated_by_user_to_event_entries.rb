class AddValidatedByUserToEventEntries < ActiveRecord::Migration
  def change
    add_column :event_entries, :validated_by_user, :string, :limit => 32
  end
end
