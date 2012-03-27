## encoding: UTF-8

class MonitorController < ApplicationController

  param_accessible /.+/

  def overview
    @members_count = Member.count
  end
end
