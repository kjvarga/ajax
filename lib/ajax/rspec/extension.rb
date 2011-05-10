module Ajax
  module RSpec
    module Extension
      # Enable and unmock
      def integrate_ajax
        Ajax.enabled = true
        Ajax.mocked = false
      end

      # Disable
      def disable_ajax
        Ajax.enabled = false
      end
      alias_method :unmock_ajax, :disable_ajax

      # Enable and mock
      def mock_ajax
        Ajax.enabled = true
        Ajax.mocked = true
      end
    end
  end
end
