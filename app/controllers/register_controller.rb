## encoding: UTF-8

class RegisterController < ApplicationController

  def choose_person
    render_choose_person_properly
  end

  def compose_transaction
    @tab = params[:tab].to_i
    @tab = 0 unless (0..2).include?(@tab)
    
    if params[:member_id]
      @member = Member.joins(:person)\
                      .with_virtual_attributes(:full_name)\
                      .find(params[:member_id])
    elsif params[:guest]
      @guest = Guest.new(params[:guest])
      # raise @guest.attributes.inspect
    end
    
    unless @member || @guest
      flash.now[:error] = t('flash.actions.other.failure')
      render_choose_person_properly
    end

    case @tab
    when 0
    when 1
    when 2
    end

  end

  def create_transaction
  end


  private

    def render_choose_person_properly
      @members = paginate(Member.joins(:person)\
                                .with_virtual_attributes(:ordered_full_name)\
                                .default_order)
      @guest ||= Guest.new(params[:guest])
      @title = t('register.choose_person.title')

      render :choose_person
    end

end
