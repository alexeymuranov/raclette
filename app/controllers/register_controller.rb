## encoding: UTF-8

class RegisterController < ApplicationController
  def choose_person
    @members = paginate(Member.joins(:person)\
                              .with_virtual_attributes(:ordered_full_name)\
                              .default_order)
  end

  def compose_transaction
    @tab = params[:tab].to_i
    @tab = 0 unless (0..2).include?(@tab)
  end

  def create_transaction
  end
end
