class CreateMemberShortHistories < ActiveRecord::Migration
  def self.up
    create_table :member_short_histories, :primary_key => :member_id do |t|
      t.primary_key :member_id
      t.date :last_active_membership_expiration_date
      t.date :prev_membership_expiration_date
      t.string :prev_membership_type
      t.integer :prev_membership_duration_months

      t.timestamps
    end
  end

  def self.down
    drop_table :member_short_histories
  end
end
