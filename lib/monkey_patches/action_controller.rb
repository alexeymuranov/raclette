# Based on http://jonathanleighton.com/articles/2011/mass-assignment-security-shouldnt-happen-in-the-model/

require 'set'
require 'app_param_filters/param_security_filter'
require 'app_param_filters/param_security_rules'

class ActionController::Base

  module ParamSecurity
    extend ActiveSupport::Concern

    included do
      class_attribute :param_security_rules
    end

    module ClassMethods
      # Some sort of dinky DSL so you can do e.g.
      #
      #   param_protected :user => [:role, :email]
      #
      # or
      #
      #   param_accessible :user => [:name, :password], :only => :create

      def param_accessible(action_params, options={})
        self.param_security_rules ||= ParamSecurityRules.new
        action_params = Hash.my_deep_collection_to_hash(action_params)
        if only_actions = options[:only]
          only_actions = normalize_action_name_collection(only_actions)
          param_security_rules.set_whitelist_for_actions(action_params,
                                                         only_actions)
        elsif except_actions = options[:except]
          except_actions = normalize_action_name_collection(except_actions)
          param_security_rules.remember_actions(except_actions)
          actions = param_security_rules.remembered_actions - except_actions
          param_security_rules.set_whitelist_for_actions(action_params, actions)
          param_security_rules.set_whitelist_for_other_actions(action_params)
        else
          actions = param_security_rules.remembered_actions
          param_security_rules.set_whitelist_for_actions(action_params, actions)
          param_security_rules.set_whitelist_for_other_actions(action_params)
        end
      end

      private

        def normalize_action_name_collection(action_names)
          unless action_names.is_a?(Set)
            action_names = ( action_names.is_a?(Enumerable) ?
                             action_names.to_set : Set[action_names] )
          end
          action_names.map!(&:to_sym)
        end

    end

    # def reset_param_security_rules
    #   self.param_security_rules = nil
    # end

    # Can be overridden if necessary
    def param_security_filter
      ParamSecurityFilter.new(self.class.param_security_rules, action_name)
    end
  end

  include ParamSecurity

  before_filter :filter_params

  attr_reader :original_params

  def filter_params
    @original_params = params
    self.params = param_filters.inject(params) do |mem, filter|
      filter.process(mem)
    end
    # params[:original_params] = @original_params # for debugging
    # params[:param_security_rules] = self.class.param_security_rules # for debugging
  end

  # Define filter(s) which operating on incoming params. Can be overridden to
  # extend/customise the filter list.
  def param_filters
    [ param_security_filter ]
  end
end
