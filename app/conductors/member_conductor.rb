# class MemberConductor < ActiveConductor  # NOTE:experimental, not used yet
#   def models
#     [member, person]
#   end
#
#   def member
#     @member ||= Member.new
#   end
#
#   def person
#     @person ||= Person.new
#   end
#
#   # conduct :member, :tickets_count
#   # conduct :person, :first_name, :last_name
# end

class MemberConductor < Member
  def models
    [member, person]
  end

  def member
    @member ||= Member.new
  end

  def person
    @person ||= Person.new
  end
end
