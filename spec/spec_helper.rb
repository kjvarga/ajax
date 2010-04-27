require 'spec'
require 'spec/autorun'
require 'rubygems'
require 'ajax/spec/extension'

# Just drop in 'debugger' to debug test code
require 'ruby-debug'

# Rails dependencies
gem 'actionpack', '2.3.5'
require 'action_controller'
require 'active_support/core_ext'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'rails', 'init')

Spec::Runner.configure do |config|
  include Ajax::Spec::Extension
end