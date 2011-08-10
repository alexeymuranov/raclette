## encoding: UTF-8

class ManagerToolsController < ManagerController
  def overview
    @weekly_events = WeeklyEvent.default_order
    @memberships = Membership.default_order
    @membership_types = MembershipType.default_order
    @activity_periods = ActivityPeriod.default_order
    @lesson_supervisions = LessonSupervision.default_order
    @instructors = Instructor.default_order
  end
end
