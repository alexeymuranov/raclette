require 'set'

require 'monkey_patches/my_dirty_hacks'

class ParamSecurityRules

  class BlackWhiteList
    attr_reader :blacklist, :whitelist

    # def select_whitelist
    #   unless whitelist
    #     @blacklist = nil
    #     @whitelist = {}
    #   end
    # end

    # def select_blacklist
    #   unless blacklist
    #     @whitelist = nil
    #     @blacklist = {}
    #   end
    # end

    def blacklist=(val)
      @whitelist = nil
      @blacklist = val
    end

    def whitelist=(val)
      @blacklist = nil
      @whitelist = val
    end

    def blacklist?
      !@blacklist.nil?
    end

    def whitelist?
      !@whitelist.nil?
    end

    def void?
      @blacklist.nil? && @whitelist.nil?
    end

    def initialize_copy(source)
      super
      if whitelist?
        @whitelist = @whitelist.deep_dup 
      elsif blacklist?  
        @blacklist = @blacklist.deep_dup 
      end
    end
  end

  def initialize
    @remembered_actions_bwls = {}
    @other_actions_bwl = BlackWhiteList.new
  end

  def remember_actions(actions)
    actions.each do |action|
      @remembered_actions_bwls[action] = @other_actions_bwl.dup\
        unless @remembered_actions_bwls.has_key?(action)
    end
  end

  def forget_actions(actions)
    actions.each do |action|
      @remembered_actions_bwls.delete(action)\
        if @remembered_actions_bwls.has_key?(action)
    end
  end

  def forget_actions_except(actions)
    @remembered_actions_bwls.each_key do |action|
      @remembered_actions_bwls.delete(action)\
        unless actions.include?(action)
    end
  end

  def forget_all_actions
    @remembered_actions_bwls = {}
  end

  def set_whitelist_for_actions(action_params, actions)
    actions.each do |action|
      unless @remembered_actions_bwls.has_key?(action)
        @remembered_actions_bwls[action] = @other_actions_bwl.dup
      end
      bwlist = @remembered_actions_bwls[action]
      if bwlist.void?
        bwlist.whitelist = action_params
      elsif bwlist.whitelist?
        bwlist.whitelist = bwlist.whitelist.deep_merge(action_params)
      else
        bwlist.blacklist = bwlist.blacklist.my_deep_remove(action_params)
      end
    end
  end

  def set_blacklist_for_actions(action_params, actions)
    actions.each do |action|
      unless @remembered_actions_bwls.has_key?(action)
        @remembered_actions_bwls[action] = @other_actions_bwl.dup
      end
      bwlist = @remembered_actions_bwls[action]
      if bwlist.void?
        bwlist.blacklist = action_params
      elsif bwlist.whitelist?
        bwlist.whitelist = bwlist.whitelist.my_deep_remove(action_params)
      else
        bwlist.blacklist = bwlist.blacklist.deep_merge(action_params)
      end
    end
  end

  def set_whitelist_for_other_actions(action_params)
    if @other_actions_bwl.void?
      @other_actions_bwl.whitelist = action_params
    elsif @other_actions_bwl.whitelist?
      @other_actions_bwl.whitelist =
        @other_actions_bwl.whitelist.deep_merge(action_params)
    else
      @other_actions_bwl.blacklist =
        @other_actions_bwl.blacklist.my_deep_remove(action_params)
    end
  end

  def set_blacklist_for_other_actions(action_params)
    if @other_actions_bwl.void?
      @other_actions_bwl.blacklist = action_params
    elsif @other_actions_bwl.whitelist?
      @other_actions_bwl.whitelist =
        @other_actions_bwl.whitelist.my_deep_remove(action_params)
    else
      @other_actions_bwl.blacklist =
        @other_actions_bwl.blacklist.deep_merge(action_params)
    end
  end

  def bwlist_for_action(action)
    if @remembered_actions_bwls.has_key?(action)
      return @remembered_actions_bwls[action]
    else
      return @other_actions_bwl
    end
  end

  def action_remembered?(action)
    @remembered_actions_bwls.has_key?(action)
  end

  def remembered_actions
    @remembered_actions_bwls.keys.to_set
  end
end
