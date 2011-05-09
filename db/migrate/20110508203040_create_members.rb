class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members, :primary_key => :person_id do |t|
      t.primary_key :person_id
      t.date        :been_member_by,       :null => false
      t.integer     :shares_tickets_with_member_id
      t.boolean     :account_deactivated,
                        :default => false, :null => false
      t.date        :latest_membership_obtained_on
      t.date        :latest_membership_expiration_date
      t.string      :latest_membership_type,            :limit => 32
      t.integer     :latest_membership_duration_months, :limit =>  1,
                        :default => 12
      t.date        :last_card_printed_on
      t.boolean     :last_card_delivered,
                        :default => false
      t.date        :last_payment_date
      t.date        :last_entry_date
      t.integer     :payed_tickets_count,               :limit =>  2,
                        :default => 0,     :null => false
      t.integer     :free_tickets_count,                :limit =>  2,
                        :default => 0,     :null => false

      t.timestamps
    end

    # add_index :members, :person_id, :unique => true
    add_index :members, :been_member_by
    add_index :members, :shares_tickets_with_member_id,
                  :unique => true
    add_index :members, :account_deactivated
    add_index :members, :latest_membership_obtained_on
    add_index :members, [ :latest_membership_expiration_date,
                          :latest_membership_obtained_on ],
                  :name => 'index_members_on'\
                           '_l_membership_expiration_d_and_l_m_obtained_on'
    add_index :members, [ :latest_membership_type,
                          :latest_membership_expiration_date ],
                  :name => 'index_members_on'\
                           '_latest_m_type_and_l_m_expiration_d'
    add_index :members, [ :latest_membership_duration_months,
                          :latest_membership_expiration_date ],
                  :name => 'index_members_on'\
                           '_latest_m_duration_m_and_l_m_expiration_d'
    add_index :members, [ :last_card_delivered, :last_card_printed_on ],
                  :name => 'index_members_on'\
                           '_last_card_delivered_and_l_c_printed_on'
  end

  def self.down
    drop_table :members
  end
end
