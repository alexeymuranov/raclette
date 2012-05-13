## encoding: UTF-8

module MembershipsHelper
  def membership_summary_in_period_type_grid(membership) # WIP
    ip = number_to_currency(membership.initial_price, :unit => '€')
    cp = number_to_currency(membership.current_price, :unit => '€')
    "#{ ip } : #{ cp } : #{ membership.members_count }"
  end
end