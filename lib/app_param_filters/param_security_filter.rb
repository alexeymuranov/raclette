class ParamSecurityFilter

  def initialize(param_security_rules, action_name)
    @filter = param_security_rules.bwlist_for_action(action_name.to_sym) unless param_security_rules.nil?
  end

  def process(param_hash)
    if @filter.whitelist
      param_hash.my_deep_filter! @filter.whitelist
    else
      param_hash.my_deep_remove! @filter.blacklist
    end unless @filter.nil? || @filter.void?
  end
end
