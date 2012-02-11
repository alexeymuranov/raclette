## encoding: UTF-8

class ManagerToolsController < ManagerController
  def overview
#     @weekly_events = WeeklyEvent.default_order
#     @memberships = Membership.default_order
#     @membership_types = MembershipType.default_order
#     @activity_periods = ActivityPeriod.default_order
#     @lesson_supervisions = LessonSupervision.default_order
    # @instructors = Instructor.joins(:person)\
    #                  .with_virtual_attributes(:ordered_full_name, :full_name).default_order
    @instructors = Instructor.joins(:person)\
                     .with_virtual_attributes(:ordered_full_name, :full_name).default_order
    @events = Event.default_order
  end
end
