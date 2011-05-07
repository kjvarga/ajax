module Ajax
  module RSpec
    module Extension
      def integrate_ajax
        Ajax.enabled = true
      end

      def disable_ajax
        Ajax.enabled = false
      end

      def mock_ajax
        integrate_ajax
        Ajax.mocked = true
      end

      def unmock_ajax
        disable_ajax
        Ajax.mocked = false
      end
    end
  end
end