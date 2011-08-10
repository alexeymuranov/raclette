## encoding: UTF-8

class SecretaryToolsController < SecretaryController
  def overview
    @members = Member.default_order
    @events = Event.default_order
  end
end
