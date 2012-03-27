## encoding: UTF-8

class ManagerToolsController < ManagerController

  param_accessible /.+/

  def overview
    event_count = Event.count
    if event_count > 50
      @events = event_count
    else
      @events = Event.default_order
    end

    @weekly_events = WeeklyEvent.default_order
#     @memberships = Membership.default_order
    @ticket_books = TicketBook.default_order
    @membership_types = MembershipType.default_order
    @activity_periods = ActivityPeriod.default_order
#     @lesson_supervisions = LessonSupervision.default_order
    @instructors = Instructor.joins(:person)\
                     .with_virtual_attributes(:ordered_full_name, :full_name).default_order
  end
end
