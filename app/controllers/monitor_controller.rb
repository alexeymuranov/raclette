## encoding: UTF-8

class MonitorController < ApplicationController
  def overview
    @members_count = Member.count
  end
end
