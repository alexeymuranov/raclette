## encoding: UTF-8

class RegisterController < ApplicationController
  def overview
    @tab = params[:tab].to_i
    @tab = 0 unless (0..2).include?(@tab)
  end
end
