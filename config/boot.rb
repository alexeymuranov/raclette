require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# NOTE
# Workaround to fix a 'psych'-related problem after upgrading to ruby 1.9.2-p290
 require 'yaml'
 YAML::ENGINE.yamler = 'syck'
# -Alexey, 2011-07-19
