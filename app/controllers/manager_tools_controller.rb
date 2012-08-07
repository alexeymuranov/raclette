## encoding: UTF-8

class ManagerToolsController < ManagerController

  def overview
    @weekly_events = Accessors::WeeklyEvent.default_order
#     @memberships = Accessors::Membership.default_order
    @ticket_books = Accessors::TicketBook.default_order
    @membership_types = Accessors::MembershipType.default_order
    @activity_periods = Accessors::ActivityPeriod.default_order
    @instructors = Accessors::Instructor.joins(:person)\
                     .with_pseudo_columns(:ordered_full_name, :full_name).default_order
  end
end
