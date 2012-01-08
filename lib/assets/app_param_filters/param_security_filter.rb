require 'set'

require 'monkey_patches/my_dirty_hacks'

class ParamSecurityFilter

  def initialize(param_security_rules, action_name)
    if param_security_rules.is_a?(Hash)
      filter = param_security_rules[:whitelist][action_name.to_sym]
      unless filter.nil?
        # @param_whitelist_filter = { :controller         => nil,
        #                             :action             => nil,
        #                             :utf8               => nil,
        #                             :_method            => nil,
        #                             :authenticity_token => nil }
        # path_parameters.keys.each { |key| @param_whitelist_filter[key] = nil }
        # @param_whitelist_filter.merge!(filter)

        @param_whitelist_filter = filter
      end
    end
  end

  def process(param_hash)
    param_hash.deep_filter! @param_whitelist_filter
  end
end
