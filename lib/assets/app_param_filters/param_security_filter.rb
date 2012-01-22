require 'set'

require 'monkey_patches/my_dirty_hacks'
require 'assets/app_param_filters/param_security_rules'

class ParamSecurityFilter

  def initialize(param_security_rules, action_name)
    @filter = param_security_rules.bwlist_for_action(action_name.to_sym) unless param_security_rules.nil?
  end

  def process(param_hash)
    if @filter.whitelist
      param_hash.deep_filter! @filter.whitelist
    else
      param_hash.deep_except! @filter.blacklist
    end unless @filter.nil? || @filter.void?
  end
end
