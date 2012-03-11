## encoding: UTF-8

class SecretaryToolsController < SecretaryController
  def overview
    @members = paginate(Member.joins(:person).
                          with_virtual_attributes(:ordered_full_name,
                                                  :full_name).default_order)
    @events = Event.default_order
  end
end
