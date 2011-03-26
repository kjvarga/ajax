# Only require integration module when extensions are included.
# RSpec integration.  Add a before filter to disable Ajax before all tests.
module Ajax::RSpec::Integration
  if defined?(RSpec)
    RSpec.configure do |c|
      c.before do
        ::Ajax.enabled = false
      end
    end
  elsif defined?(Spec)
    Spec::Runner.configure do |c|
      c.before :all do
        ::Ajax.enabled = false
      end
    end
  end
end

# ActiveSupport::TestCase integration
module ActiveSupport
  class TestCase
    include Ajax::RSpec::Extension
  end
end