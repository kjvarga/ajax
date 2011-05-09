require 'ajax/rspec/extension'
require 'ajax/rspec/helpers'

# RSpec integration.  Add a before filter to disable Ajax before all tests.
# Make the methods in Ajax::RSpec::Extension available in your example groups.
#
# Call <tt>Ajax::RSpec.setup</tt> to retry adding the test integration.
# This can be useful if RSpec is not defined at the time that Ajax is initialized.
module Ajax::RSpec
  def self.setup
    if defined?(::RSpec)
      ::RSpec.configure do |c|
        c.include(Ajax::RSpec::Extension)
        c.before :all do
          Ajax.enabled = false
        end
      end
    elsif defined?(::Spec::Runner)
      ::Spec::Runner.configure do |c|
        c.include(Ajax::RSpec::Extension)
        c.before :all do
          Ajax.enabled = false
        end
      end
    elsif defined?(ActiveSupport::TestCase)
      ActiveSupport::TestCase.send(:include, Ajax::RSpec::Extension) unless ActiveSupport::TestCase.include?(Ajax::RSpec::Extension)
    end
  end
end

Ajax::RSpec.setup
