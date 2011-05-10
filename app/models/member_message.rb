class MemberMessage < ActiveRecord::Base

  attr_readonly :id, :member_id

  # attr_accessible( # :id,
                   # :member_id,
                   # :content,
                   # :created_on
                 # )  ## all attributes listed here

  belongs_to :member, :inverse_of => :member_message
end
