## encoding: UTF-8

class SecretaryToolsController < SecretaryController

  def overview
    member_count = Accessors::Member.count
    if member_count > 50
      @members = member_count
    else
      @members = Accessors::Member.joins(:person).
        with_pseudo_columns(:ordered_full_name, :full_name).default_order
    end

    event_count = Accessors::Event.count
    if event_count > 50
      @events = event_count
    else
      @events = Accessors::Event.default_order
    end

     @lesson_supervisions = Accessors::LessonSupervision.default_order
  end
end
