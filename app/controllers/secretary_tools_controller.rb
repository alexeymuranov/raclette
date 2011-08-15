## encoding: UTF-8

class SecretaryToolsController < SecretaryController
  def overview
    @members = Member.with_person_and_virtual_attributes.default_order
    @events = Event.default_order
  end
end
