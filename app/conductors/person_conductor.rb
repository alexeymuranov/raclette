# class PersonConductor # < ActiveConductor  # NOTE:experimental, not used yet
#   def models
#     [person]
#   end
#
#   def person
#     @person ||= Person.new
#   end
#
#   # conduct :person, :first_name, :last_name
# end

class PersonConductor < Person
  def models
    [person]
  end

  def person
    @person ||= Person.new
  end
end
