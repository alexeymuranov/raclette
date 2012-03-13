## encoding: UTF-8

class SecretaryToolsController < SecretaryController
  def overview
    member_count = Member.count
    if member_count > 50
      @members = member_count
    else
      @members = Member.joins(:person).
        with_virtual_attributes(:ordered_full_name, :full_name).default_order
    end

    event_count = Event.count
    if event_count > 50
      @events = event_count
    else
      @events = Event.default_order
    end
  end
end
