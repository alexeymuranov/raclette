class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members, :primary_key => :person_id do |t|
      t.primary_key :person_id
      t.date :been_member_by
      t.integer :shares_tickets_with_member_id
      t.boolean :account_deactivated
      t.date :latest_membership_obtained_on
      t.date :latest_membership_expiration_date
      t.string :latest_membership_type
      t.integer :latest_membership_duration_months
      t.date :last_card_printed_on
      t.boolean :last_card_delivered
      t.date :last_payment_date
      t.date :last_entry_date
      t.integer :payed_tickets_count
      t.integer :free_tickets_count

      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
