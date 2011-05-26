require 'bundler/setup'
Bundler.require
require 'rspec/autorun'
require 'ajax/rspec'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

RSpec.configure do |config|
  config.include(Ajax::RSpec::RequestHelpers)
  config.mock_with :mocha
  # config.filter_run :focus => true
end
