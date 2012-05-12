## encoding: UTF-8

class ManagerToolsController < ManagerController

  param_accessible /.+/

  def overview
    @weekly_events = WeeklyEvent.default_order
#     @memberships = Membership.default_order
    @ticket_books = TicketBook.default_order
    @membership_types = MembershipType.default_order
    @activity_periods = ActivityPeriod.default_order
    @instructors = Instructor.joins(:person)\
                     .with_virtual_attributes(:ordered_full_name, :full_name).default_order
  end
end
