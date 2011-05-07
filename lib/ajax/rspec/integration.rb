# Only require integration module when extensions are included.
# RSpec integration.  Add a before filter to disable Ajax before all tests.
module Ajax::RSpec::Integration
  if defined?(::RSpec)
    ::RSpec.configure do |c|
      c.include(Ajax::RSpec::Extension)
      c.before :all do
        disable_ajax
      end
    end
  elsif defined?(::Spec::Runner)
    ::Spec::Runner.configure do |c|
      include Ajax::RSpec::Extension
      c.before :all do
        disable_ajax
      end
    end
  elsif defined?(ActiveSupport::TestCase)
    ActiveSupport::TestCase.send(:include, Ajax::RSpec::Extension)
  end
end
