## encoding: UTF-8

class SecretaryToolsController < SecretaryController
  def overview
    @members = Member.joins(:person)\
                     .with_virtual_attributes(:ordered_full_name, :full_name)
    @events = Event.default_order
  end
end
