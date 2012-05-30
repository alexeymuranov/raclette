# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120530230208) do

  create_table "activity_periods", :force => true do |t|
    t.string   "unique_title",    :limit => 64,                    :null => false
    t.date     "start_date",                                       :null => false
    t.integer  "duration_months", :limit => 1,  :default => 12,    :null => false
    t.date     "end_date",                                         :null => false
    t.boolean  "over",                          :default => false, :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activity_periods", ["duration_months"], :name => "index_activity_periods_on_duration_months"
  add_index "activity_periods", ["end_date"], :name => "index_activity_periods_on_end_date"
  add_index "activity_periods", ["over", "end_date"], :name => "index_activity_periods_on_over_and_end_date"
  add_index "activity_periods", ["start_date"], :name => "index_activity_periods_on_start_date"
  add_index "activity_periods", ["unique_title"], :name => "index_activity_periods_on_unique_title", :unique => true

  create_table "addresses", :force => true do |t|
    t.string   "names",          :limit => 64, :null => false
    t.string   "address_type",   :limit => 32
    t.string   "country",        :limit => 32, :null => false
    t.string   "city",           :limit => 32
    t.string   "post_code",      :limit => 16
    t.string   "street_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["address_type"], :name => "index_addresses_on_address_type"
  add_index "addresses", ["city", "country"], :name => "index_addresses_on_city_and_country"
  add_index "addresses", ["country"], :name => "index_addresses_on_country"
  add_index "addresses", ["names"], :name => "index_addresses_on_names"
  add_index "addresses", ["post_code", "country"], :name => "index_addresses_on_post_code_and_country"

  create_table "admin_known_ips", :force => true do |t|
    t.string   "ip",          :limit => 15, :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_known_ips", ["ip"], :name => "index_admin_known_ips_on_ip", :unique => true

  create_table "admin_safe_user_ips", :force => true do |t|
    t.integer  "known_ip_id",  :null => false
    t.integer  "user_id",      :null => false
    t.datetime "last_used_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_safe_user_ips", ["known_ip_id"], :name => "index_admin_safe_user_ips_on_known_ip_id"
  add_index "admin_safe_user_ips", ["user_id", "known_ip_id"], :name => "index_admin_safe_user_ips_on_user_id_and_known_ip_id", :unique => true

  create_table "admin_users", :force => true do |t|
    t.string   "username",                  :limit => 32,                    :null => false
    t.string   "full_name",                 :limit => 64,                    :null => false
    t.boolean  "a_person",                                                   :null => false
    t.integer  "person_id"
    t.string   "email"
    t.boolean  "account_deactivated",                     :default => false, :null => false
    t.boolean  "admin",                                   :default => false, :null => false
    t.boolean  "manager",                                 :default => false, :null => false
    t.boolean  "secretary",                               :default => false, :null => false
    t.string   "password_or_password_hash",               :default => "",    :null => false
    t.string   "password_salt"
    t.datetime "last_signed_in_at"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_signed_in_from_ip",    :limit => 15
    t.datetime "last_seen_at"
  end

  add_index "admin_users", ["a_person"], :name => "index_admin_users_on_a_person"
  add_index "admin_users", ["admin"], :name => "index_admin_users_on_admin"
  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["full_name"], :name => "index_admin_users_on_full_name"
  add_index "admin_users", ["person_id"], :name => "index_admin_users_on_person_id"
  add_index "admin_users", ["username"], :name => "index_admin_users_on_username", :unique => true

  create_table "application_journal", :force => true do |t|
    t.string   "action",         :limit => 64, :null => false
    t.string   "username",       :limit => 32, :null => false
    t.integer  "user_id"
    t.string   "ip",             :limit => 15, :null => false
    t.string   "something_type", :limit => 32, :null => false
    t.integer  "something_id"
    t.string   "details"
    t.datetime "generated_at",                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committee_memberships", :force => true do |t|
    t.integer  "person_id",                                   :null => false
    t.string   "function",   :limit => 64,                    :null => false
    t.date     "start_date",                                  :null => false
    t.date     "end_date"
    t.boolean  "quit",                     :default => false, :null => false
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "committee_memberships", ["end_date"], :name => "index_committee_memberships_on_end_date"
  add_index "committee_memberships", ["person_id"], :name => "index_committee_memberships_on_person_id"
  add_index "committee_memberships", ["quit", "end_date"], :name => "index_committee_memberships_on_quit_and_end_date"
  add_index "committee_memberships", ["start_date"], :name => "index_committee_memberships_on_start_date"

  create_table "event_cashiers", :force => true do |t|
    t.integer  "event_id"
    t.string   "name",        :limit => 64, :null => false
    t.integer  "person_id"
    t.datetime "started_at",                :null => false
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_cashiers", ["event_id"], :name => "index_event_cashiers_on_event_id"
  add_index "event_cashiers", ["finished_at"], :name => "index_event_cashiers_on_finished_at"
  add_index "event_cashiers", ["name"], :name => "index_event_cashiers_on_name"
  add_index "event_cashiers", ["person_id"], :name => "index_event_cashiers_on_person_id"
  add_index "event_cashiers", ["started_at"], :name => "index_event_cashiers_on_started_at"

  create_table "event_entries", :force => true do |t|
    t.string   "participant_entry_type", :limit => 32, :null => false
    t.integer  "participant_entry_id"
    t.string   "event_title",            :limit => 64, :null => false
    t.date     "date",                                 :null => false
    t.integer  "event_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "validated_by_user",      :limit => 32
  end

  add_index "event_entries", ["date"], :name => "index_event_entries_on_date"
  add_index "event_entries", ["event_id", "person_id"], :name => "index_event_entries_on_event_id_and_person_id", :unique => true
  add_index "event_entries", ["participant_entry_type", "participant_entry_id"], :name => "index_event_entries_on_participant_entry_type_and_p_e_id", :unique => true
  add_index "event_entries", ["participant_entry_type"], :name => "index_event_entries_on_participant_entry_type"
  add_index "event_entries", ["person_id"], :name => "index_event_entries_on_person_id"

  create_table "event_entry_reservations", :force => true do |t|
    t.integer  "event_id",                                                                               :null => false
    t.integer  "people_number",           :limit => 1,                                :default => 1,     :null => false
    t.string   "names",                   :limit => 64,                                                  :null => false
    t.integer  "member_id"
    t.integer  "previous_guest_entry_id"
    t.string   "contact_email"
    t.string   "contact_phone",           :limit => 32
    t.decimal  "amount_payed",                          :precision => 3, :scale => 1, :default => 0.0,   :null => false
    t.boolean  "cancelled",                                                           :default => false, :null => false
    t.string   "note"
    t.datetime "created_at",                                                                             :null => false
    t.datetime "updated_at",                                                                             :null => false
  end

  add_index "event_entry_reservations", ["cancelled"], :name => "index_event_entry_reservations_on_cancelled"
  add_index "event_entry_reservations", ["event_id", "member_id"], :name => "index_event_entry_reservations_on_event_id_and_member_id", :unique => true
  add_index "event_entry_reservations", ["event_id", "names"], :name => "index_event_entry_reservations_on_event_id_and_names", :unique => true
  add_index "event_entry_reservations", ["event_id", "previous_guest_entry_id"], :name => "index_event_entry_reservations_on_event_id_and_prev_g_entry_id", :unique => true
  add_index "event_entry_reservations", ["member_id"], :name => "index_event_entry_reservations_on_member_id"
  add_index "event_entry_reservations", ["names"], :name => "index_event_entry_reservations_on_names"
  add_index "event_entry_reservations", ["people_number"], :name => "index_event_entry_reservations_on_people_number"
  add_index "event_entry_reservations", ["previous_guest_entry_id"], :name => "index_event_entry_reservations_on_previous_guest_entry_id"

  create_table "events", :force => true do |t|
    t.string   "event_type",            :limit => 32,                                                  :null => false
    t.string   "title",                 :limit => 64
    t.boolean  "locked",                                                            :default => false, :null => false
    t.boolean  "lesson",                                                                               :null => false
    t.date     "date"
    t.time     "start_time",            :limit => 8
    t.time     "end_time",              :limit => 8
    t.string   "location",              :limit => 64
    t.integer  "address_id"
    t.boolean  "weekly",                                                            :default => false, :null => false
    t.integer  "weekly_event_id"
    t.string   "supervisors"
    t.integer  "lesson_supervision_id"
    t.integer  "entry_fee_tickets",     :limit => 1
    t.decimal  "member_entry_fee",                    :precision => 3, :scale => 1
    t.decimal  "couple_entry_fee",                    :precision => 3, :scale => 1
    t.decimal  "common_entry_fee",                    :precision => 3, :scale => 1
    t.boolean  "over",                                                              :default => false, :null => false
    t.integer  "reservations_count",    :limit => 2,                                :default => 0
    t.integer  "entries_count",         :limit => 2,                                :default => 0
    t.integer  "member_entries_count",  :limit => 2,                                :default => 0
    t.integer  "tickets_collected",     :limit => 2,                                :default => 0
    t.decimal  "entry_fees_collected",                :precision => 6, :scale => 1, :default => 0.0
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time     "duration"
  end

  add_index "events", ["address_id"], :name => "index_events_on_address_id"
  add_index "events", ["date"], :name => "index_events_on_date"
  add_index "events", ["event_type", "title"], :name => "index_events_on_event_type_and_title"
  add_index "events", ["lesson"], :name => "index_events_on_lesson"
  add_index "events", ["lesson_supervision_id"], :name => "index_events_on_lesson_supervision_id"
  add_index "events", ["locked", "date"], :name => "index_events_on_locked_and_date"
  add_index "events", ["over", "date"], :name => "index_events_on_over_and_date"
  add_index "events", ["title", "date"], :name => "index_events_on_title_and_date"
  add_index "events", ["weekly"], :name => "index_events_on_weekly"
  add_index "events", ["weekly_event_id"], :name => "index_events_on_weekly_event_id"

  create_table "guest_entries", :force => true do |t|
    t.string   "first_name",                    :limit => 32, :null => false
    t.string   "last_name",                     :limit => 32
    t.integer  "inviting_member_id"
    t.integer  "previous_entry_id"
    t.integer  "toward_membership_purchase_id"
    t.string   "email"
    t.string   "phone",                         :limit => 32
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guest_entries", ["first_name"], :name => "index_guest_entries_on_first_name"
  add_index "guest_entries", ["inviting_member_id"], :name => "index_guest_entries_on_inviting_member_id"
  add_index "guest_entries", ["last_name", "first_name"], :name => "index_guest_entries_on_last_name_and_first_name"
  add_index "guest_entries", ["previous_entry_id"], :name => "index_guest_entries_on_previous_entry_id", :unique => true
  add_index "guest_entries", ["toward_membership_purchase_id"], :name => "index_guest_entries_on_toward_membership_purchase_id"

  create_table "instructors", :primary_key => "person_id", :force => true do |t|
    t.text     "presentation"
    t.binary   "photo"
    t.date     "employed_from"
    t.date     "employed_until"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instructors", ["employed_from"], :name => "index_instructors_on_employed_from"
  add_index "instructors", ["employed_until"], :name => "index_instructors_on_employed_until"

  create_table "lesson_instructors", :force => true do |t|
    t.integer  "lesson_supervision_id",                    :null => false
    t.integer  "instructor_id",                            :null => false
    t.boolean  "invited",               :default => false, :null => false
    t.boolean  "volunteer",             :default => false, :null => false
    t.boolean  "assistant",             :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lesson_instructors", ["assistant"], :name => "index_lesson_instructors_on_assistant"
  add_index "lesson_instructors", ["instructor_id"], :name => "index_lesson_instructors_on_instructor_id"
  add_index "lesson_instructors", ["invited"], :name => "index_lesson_instructors_on_invited"
  add_index "lesson_instructors", ["lesson_supervision_id", "instructor_id"], :name => "index_lesson_instructors_on_lesson_supervision_id_and_i_id", :unique => true
  add_index "lesson_instructors", ["volunteer"], :name => "index_lesson_instructors_on_volunteer"

  create_table "lesson_supervisions", :force => true do |t|
    t.string   "unique_names",      :limit => 128,                :null => false
    t.integer  "instructors_count", :limit => 1,   :default => 1, :null => false
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lesson_supervisions", ["instructors_count"], :name => "index_lesson_supervisions_on_instructors_count"
  add_index "lesson_supervisions", ["unique_names"], :name => "index_lesson_supervisions_on_unique_names", :unique => true

  create_table "member_entries", :force => true do |t|
    t.integer  "member_id",                                  :null => false
    t.integer  "guests_invited",              :default => 0
    t.integer  "tickets_used",   :limit => 1, :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_entries", ["member_id", "guests_invited"], :name => "index_member_entries_on_member_id_and_guests_invited"

  create_table "member_memberships", :force => true do |t|
    t.integer  "member_id",     :null => false
    t.integer  "membership_id", :null => false
    t.date     "obtained_on",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_memberships", ["member_id", "membership_id"], :name => "index_member_memberships_on_member_id_and_membership_id", :unique => true
  add_index "member_memberships", ["membership_id"], :name => "index_member_memberships_on_membership_id"
  add_index "member_memberships", ["obtained_on"], :name => "index_member_memberships_on_obtained_on"

  create_table "member_messages", :force => true do |t|
    t.integer  "member_id",  :null => false
    t.text     "content",    :null => false
    t.date     "created_on", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_messages", ["created_on"], :name => "index_member_messages_on_created_on"
  add_index "member_messages", ["member_id"], :name => "index_member_messages_on_member_id", :unique => true

  create_table "member_short_histories", :primary_key => "member_id", :force => true do |t|
    t.date     "last_active_membership_expiration_date"
    t.date     "prev_membership_expiration_date",                                      :null => false
    t.string   "prev_membership_type",                   :limit => 32,                 :null => false
    t.integer  "prev_membership_duration_months",        :limit => 1,  :default => 12, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "member_short_histories", ["last_active_membership_expiration_date"], :name => "index_member_short_histories_on_last_active_membership_exp_date"
  add_index "member_short_histories", ["prev_membership_duration_months"], :name => "index_member_short_histories_on_prev_membership_duration_months"
  add_index "member_short_histories", ["prev_membership_expiration_date"], :name => "index_member_short_histories_on_prev_membership_expiration_date"
  add_index "member_short_histories", ["prev_membership_type", "prev_membership_expiration_date"], :name => "index_member_short_histories_on_prev_m_type_and_p_m_exp_date"

  create_table "members", :primary_key => "person_id", :force => true do |t|
    t.date     "been_member_by",                                                     :null => false
    t.integer  "shares_tickets_with_member_id"
    t.boolean  "account_deactivated",                             :default => false, :null => false
    t.date     "latest_membership_obtained_on"
    t.date     "latest_membership_expiration_date"
    t.string   "latest_membership_type",            :limit => 32
    t.integer  "latest_membership_duration_months", :limit => 1,  :default => 12
    t.date     "last_card_printed_on"
    t.boolean  "last_card_delivered",                             :default => false
    t.date     "last_payment_date"
    t.date     "last_entry_date"
    t.integer  "payed_tickets_count",               :limit => 2,  :default => 0,     :null => false
    t.integer  "free_tickets_count",                :limit => 2,  :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["account_deactivated"], :name => "index_members_on_account_deactivated"
  add_index "members", ["been_member_by"], :name => "index_members_on_been_member_by"
  add_index "members", ["last_card_delivered", "last_card_printed_on"], :name => "index_members_on_last_card_delivered_and_l_c_printed_on"
  add_index "members", ["latest_membership_duration_months", "latest_membership_expiration_date"], :name => "index_members_on_latest_m_duration_m_and_l_m_expiration_d"
  add_index "members", ["latest_membership_expiration_date", "latest_membership_obtained_on"], :name => "index_members_on_l_membership_expiration_d_and_l_m_obtained_on"
  add_index "members", ["latest_membership_obtained_on"], :name => "index_members_on_latest_membership_obtained_on"
  add_index "members", ["latest_membership_type", "latest_membership_expiration_date"], :name => "index_members_on_latest_m_type_and_l_m_expiration_d"
  add_index "members", ["shares_tickets_with_member_id"], :name => "index_members_on_shares_tickets_with_member_id", :unique => true

  create_table "membership_purchases", :force => true do |t|
    t.integer  "member_id",                                :null => false
    t.string   "membership_type",            :limit => 32, :null => false
    t.date     "membership_expiration_date",               :null => false
    t.integer  "membership_id"
    t.date     "purchase_date",                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "validated_by_user",          :limit => 32
  end

  add_index "membership_purchases", ["member_id", "membership_id"], :name => "index_membership_purchases_on_member_id_and_membership_id", :unique => true
  add_index "membership_purchases", ["membership_expiration_date"], :name => "index_membership_purchases_on_membership_expiration_date"
  add_index "membership_purchases", ["membership_id"], :name => "index_membership_purchases_on_membership_id"
  add_index "membership_purchases", ["membership_type", "membership_expiration_date"], :name => "index_membership_purchases_on_m_type_and_m_expiration_date"
  add_index "membership_purchases", ["purchase_date"], :name => "index_membership_purchases_on_purchase_date"

  create_table "membership_types", :force => true do |t|
    t.string   "unique_title",    :limit => 32,                    :null => false
    t.boolean  "active",                        :default => false, :null => false
    t.boolean  "reduced",                       :default => false, :null => false
    t.boolean  "unlimited",                     :default => false, :null => false
    t.integer  "duration_months", :limit => 1,  :default => 12,    :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "membership_types", ["active", "reduced", "unlimited", "duration_months"], :name => "index_membership_types_on_a_and_r_and_u_and_duration_m", :unique => true
  add_index "membership_types", ["duration_months"], :name => "index_membership_types_on_duration_months"
  add_index "membership_types", ["unique_title"], :name => "index_membership_types_on_unique_title", :unique => true

  create_table "memberships", :force => true do |t|
    t.integer  "membership_type_id",                                               :null => false
    t.integer  "activity_period_id",                                               :null => false
    t.decimal  "initial_price",       :precision => 4, :scale => 1
    t.decimal  "current_price",       :precision => 4, :scale => 1
    t.integer  "tickets_count_limit"
    t.integer  "members_count",                                     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["activity_period_id", "membership_type_id"], :name => "index_memberships_on_activity_period_id_and_membership_type_id", :unique => true
  add_index "memberships", ["membership_type_id"], :name => "index_memberships_on_membership_type_id"

  create_table "payments", :force => true do |t|
    t.string   "payable_type",             :limit => 32,                                                  :null => false
    t.integer  "payable_id"
    t.date     "date",                                                                                    :null => false
    t.decimal  "amount",                                 :precision => 4, :scale => 1,                    :null => false
    t.string   "method",                   :limit => 32
    t.integer  "revenue_account_id"
    t.integer  "payer_person_id"
    t.boolean  "cancelled_and_reimbursed",                                             :default => false, :null => false
    t.date     "cancelled_on"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments", ["cancelled_and_reimbursed", "cancelled_on"], :name => "index_payments_on_cancelled_and_reimbursed_and_cancelled_on"
  add_index "payments", ["date"], :name => "index_payments_on_date"
  add_index "payments", ["payable_type", "date"], :name => "index_payments_on_payable_type_and_date"
  add_index "payments", ["payable_type", "payable_id"], :name => "index_payments_on_payable_type_and_payable_id"
  add_index "payments", ["payer_person_id"], :name => "index_payments_on_payer_person_id"
  add_index "payments", ["revenue_account_id"], :name => "index_payments_on_revenue_account_id"

  create_table "people", :force => true do |t|
    t.string   "last_name",          :limit => 32,                 :null => false
    t.string   "first_name",         :limit => 32,                 :null => false
    t.string   "name_title",         :limit => 16
    t.string   "nickname_or_other",  :limit => 32, :default => "", :null => false
    t.integer  "birthyear",          :limit => 2
    t.string   "email"
    t.string   "mobile_phone",       :limit => 32
    t.string   "home_phone",         :limit => 32
    t.string   "work_phone",         :limit => 32
    t.integer  "primary_address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["email"], :name => "index_people_on_email"
  add_index "people", ["first_name"], :name => "index_people_on_first_name"
  add_index "people", ["last_name", "first_name", "nickname_or_other"], :name => "index_people_on_last_name_and_first_name_and_nickname_or_other", :unique => true
  add_index "people", ["name_title"], :name => "index_people_on_name_title"
  add_index "people", ["nickname_or_other"], :name => "index_people_on_nickname_or_other"
  add_index "people", ["primary_address_id"], :name => "index_people_on_primary_address_id"

  create_table "personal_statements", :primary_key => "person_id", :force => true do |t|
    t.date     "birthday"
    t.boolean  "accept_email_announcements",               :default => false
    t.boolean  "volunteer",                                :default => false
    t.string   "volunteer_as"
    t.string   "preferred_language",         :limit => 32
    t.string   "occupation",                 :limit => 64
    t.string   "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "personal_statements", ["accept_email_announcements"], :name => "index_personal_statements_on_accept_email_announcements"
  add_index "personal_statements", ["volunteer"], :name => "index_personal_statements_on_volunteer"

  create_table "revenue_accounts", :force => true do |t|
    t.string   "unique_title",       :limit => 64,                                                  :null => false
    t.boolean  "locked",                                                         :default => false, :null => false
    t.integer  "activity_period_id"
    t.date     "opened_on"
    t.date     "closed_on"
    t.boolean  "main",                                                           :default => false, :null => false
    t.decimal  "amount",                           :precision => 7, :scale => 2, :default => 0.0,   :null => false
    t.date     "amount_updated_on"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "revenue_accounts", ["activity_period_id"], :name => "index_revenue_accounts_on_activity_period_id"
  add_index "revenue_accounts", ["closed_on"], :name => "index_revenue_accounts_on_closed_on"
  add_index "revenue_accounts", ["locked", "closed_on"], :name => "index_revenue_accounts_on_locked_and_closed_on"
  add_index "revenue_accounts", ["locked", "opened_on"], :name => "index_revenue_accounts_on_locked_and_opened_on"
  add_index "revenue_accounts", ["opened_on"], :name => "index_revenue_accounts_on_opened_on"
  add_index "revenue_accounts", ["unique_title"], :name => "index_revenue_accounts_on_unique_title", :unique => true

  create_table "secretary_notes", :force => true do |t|
    t.string   "note_type",          :limit => 32, :null => false
    t.string   "something_type",     :limit => 32, :null => false
    t.integer  "something_id"
    t.date     "created_on",                       :null => false
    t.text     "message"
    t.datetime "message_updated_at",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "secretary_notes", ["created_on"], :name => "index_secretary_notes_on_created_on"
  add_index "secretary_notes", ["message_updated_at"], :name => "index_secretary_notes_on_message_updated_at"
  add_index "secretary_notes", ["note_type", "message_updated_at"], :name => "index_secretary_notes_on_note_type_and_message_updated_at"
  add_index "secretary_notes", ["note_type", "something_type", "something_id"], :name => "index_secretary_notes_on_note_type_and_s_type_and_s_id", :unique => true
  add_index "secretary_notes", ["something_type", "something_id"], :name => "index_secretary_notes_on_something_type_and_something_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "ticket_books", :force => true do |t|
    t.integer  "membership_type_id",                                            :null => false
    t.integer  "tickets_number",     :limit => 2,                               :null => false
    t.decimal  "price",                           :precision => 4, :scale => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ticket_books", ["membership_type_id", "tickets_number"], :name => "index_ticket_books_on_membership_type_id_and_tickets_number", :unique => true

  create_table "tickets_purchases", :force => true do |t|
    t.integer  "member_id",                       :null => false
    t.integer  "tickets_number",    :limit => 2,  :null => false
    t.integer  "ticket_book_id"
    t.date     "purchase_date",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "validated_by_user", :limit => 32
  end

  add_index "tickets_purchases", ["member_id"], :name => "index_tickets_purchases_on_member_id"
  add_index "tickets_purchases", ["purchase_date"], :name => "index_tickets_purchases_on_purchase_date"
  add_index "tickets_purchases", ["ticket_book_id"], :name => "index_tickets_purchases_on_ticket_book_id"

  create_table "weekly_event_suspensions", :force => true do |t|
    t.integer  "weekly_event_id", :null => false
    t.date     "suspend_from",    :null => false
    t.date     "suspend_until",   :null => false
    t.string   "explanation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weekly_event_suspensions", ["suspend_from"], :name => "index_weekly_event_suspensions_on_suspend_from"
  add_index "weekly_event_suspensions", ["suspend_until"], :name => "index_weekly_event_suspensions_on_suspend_until"
  add_index "weekly_event_suspensions", ["weekly_event_id", "suspend_from"], :name => "index_weekly_event_suspensions_on_w_e_id_and_suspend_from", :unique => true
  add_index "weekly_event_suspensions", ["weekly_event_id", "suspend_until"], :name => "index_weekly_event_suspensions_on_w_e_id_and_suspend_until", :unique => true

  create_table "weekly_events", :force => true do |t|
    t.string   "event_type",            :limit => 32,                    :null => false
    t.string   "title",                 :limit => 64,                    :null => false
    t.boolean  "lesson",                                                 :null => false
    t.integer  "week_day",              :limit => 1,                     :null => false
    t.time     "start_time",            :limit => 8
    t.time     "end_time",              :limit => 8
    t.date     "start_on",                                               :null => false
    t.date     "end_on"
    t.string   "location",              :limit => 64
    t.integer  "address_id"
    t.integer  "lesson_supervision_id"
    t.integer  "entry_fee_tickets",     :limit => 1
    t.boolean  "over",                                :default => false, :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time     "duration"
  end

  add_index "weekly_events", ["address_id"], :name => "index_weekly_events_on_address_id"
  add_index "weekly_events", ["end_on"], :name => "index_weekly_events_on_end_on"
  add_index "weekly_events", ["event_type", "title"], :name => "index_weekly_events_on_event_type_and_title"
  add_index "weekly_events", ["lesson"], :name => "index_weekly_events_on_lesson"
  add_index "weekly_events", ["lesson_supervision_id"], :name => "index_weekly_events_on_lesson_supervision_id"
  add_index "weekly_events", ["over", "end_on"], :name => "index_weekly_events_on_over_and_end_on"
  add_index "weekly_events", ["start_on"], :name => "index_weekly_events_on_start_on"
  add_index "weekly_events", ["title", "end_on"], :name => "index_weekly_events_on_title_and_end_on", :unique => true
  add_index "weekly_events", ["title", "start_on"], :name => "index_weekly_events_on_title_and_start_on", :unique => true
  add_index "weekly_events", ["week_day"], :name => "index_weekly_events_on_week_day"

end
