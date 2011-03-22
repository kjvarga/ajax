require 'bundler/setup'
Bundler.require

require 'spec/autorun'
require 'ajax/spec/extension'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'rails', 'init')

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  include Ajax::Spec::Extension
  config.include(FileMacros)
end