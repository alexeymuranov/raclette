class CreateMemberShortHistories < ActiveRecord::Migration
  def up
    create_table :member_short_histories, :primary_key => :member_id do |t|
      t.primary_key :member_id
      t.date        :last_active_membership_expiration_date
      t.date        :prev_membership_expiration_date,    :null => false
      t.string      :prev_membership_type, :limit => 32, :null => false
      t.integer     :prev_membership_duration_months,
                        :default => 12,    :limit =>  1, :null => false

      t.timestamps
    end

    # add_index :member_short_histories, :member_id, :unique => true
    add_index :member_short_histories,
      :last_active_membership_expiration_date,
      :name => 'index_member_short_histories_on_last_active_membership_exp_d'
    add_index :member_short_histories,
      :prev_membership_expiration_date,
      :name => 'index_member_short_histories_on_prev_membership_expiration_d'
    add_index :member_short_histories,
      [:prev_membership_type, :prev_membership_expiration_date],
      :name => 'index_member_short_histories_on_prev_m_type_and_p_m_exp_date'
    add_index :member_short_histories,
      :prev_membership_duration_month,
      :name => 'index_member_short_histories_on_prev_membership_duration_mon'
  end

  def down
    drop_table :member_short_histories
  end
end
