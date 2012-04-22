## encoding: UTF-8

class MonitorController < ApplicationController

  param_accessible /.+/

  def overview
    # @members_count = Member.count
    # @active_members_count = Member.account_active.count
    # @current_members_count = Member.current.count
  end
end
