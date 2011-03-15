require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'ajax/spec/extension'

# Just drop in 'debugger' to debug test code
require 'ruby-debug'

# Rails dependencies
gem 'actionpack', '2.3.11'
require 'action_controller'
require 'active_support/core_ext'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'rails', 'init')

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  include Ajax::Spec::Extension
  config.include(FileMacros)
end