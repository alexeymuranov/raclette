# Based on http://jonathanleighton.com/articles/2011/mass-assignment-security-shouldnt-happen-in-the-model/

require 'assets/app_param_filters/param_security_filter'

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

      def param_accessible(action_params)
        self.param_security_rules ||= Hash::new
        self.param_security_rules.deep_merge! :whitelist => action_params
      end
    end

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
