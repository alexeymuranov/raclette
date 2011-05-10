class MemberShortHistory < ActiveRecord::Base
  set_primary_key :member_id

  attr_readonly :id, :member_id

  # attr_accessible( # :id,
                   # :member_id,
                   # :last_active_membership_expiration_date,
                   # :prev_membership_expiration_date,
                   # :prev_membership_type,
                   # :prev_membership_duration_months
                 # )  ## all attributes listed here

  belongs_to :member, :inverse_of => :short_history
end
