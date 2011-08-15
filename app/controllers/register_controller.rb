## encoding: UTF-8

class RegisterController < ApplicationController
  def choose_person
    @members = paginate(Member.with_person_and_virtual_attributes.default_order)
  end

  def compose_transaction
    @tab = params[:tab].to_i
    @tab = 0 unless (0..2).include?(@tab)
  end
  
  def create_transaction
  end
end
