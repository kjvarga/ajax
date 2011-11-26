require 'pathname'

module Ajax
  # A class with framework/application related methods like discovering
  # which version of Rails we are running under.
  class Application
    # Return a boolean indicating whether the Rails constant is defined.
    # It cannot identify Rails < 2.1
    #
    # Example:
    # rails?(3) => true if Rails major version is 3
    # rails?(3.0) => true if Rails major.minor version is 3.0
    # rails?(:>=, 3) => true if Rails major version is >= 3
    # rails?(:>=, 3.1) => true if Rails major.minor version is >= 3.1
    def rails?(*args)
      version, comparator = args.pop, (args.pop || :==)
      result =
        if version.nil?
          defined?(::Rails)
        elsif defined?(::Rails)
          if ::Rails.respond_to?(:version)
            rails_version = Rails.version.to_f
            rails_version = rails_version.floor if version.is_a?(Integer)
            rails_version.send(comparator, version.to_f)
          else
            version.to_f <= 2.0
          end
        else
          false
        end
      !!result
    end

    def root
      Pathname.new(rails? && Rails.root || Dir.getwd)
    end

    # Include framework hooks for Rails
    #
    # This method is called by <tt>init.rb</tt>, which is run by Rails on startup.
    #
    # Customize rendering.  Include custom headers and don't render the layout for AJAX.
    # Insert the Rack::Ajax middleware to rewrite and handle requests.
    # Add custom attributes to outgoing links.
    #
    # Hooks for Rails 3 are installed using Railties.
    def init
      return unless rails?
      if rails?(:>=, 3)
        require 'ajax/railtie'
      else
        require 'ajax/action_controller'
        require 'ajax/action_view'

        Ajax.logger = ::Rails.logger

        # Customize rendering.  Include custom headers and don't render the layout for AJAX.
        ::ActionController::Base.send(:include, Ajax::ActionController)

        # Insert the Rack::Ajax middleware to rewrite and handle requests
        ::ActionController::Dispatcher.middleware.insert_before(Rack::Head, Rack::Ajax)

        # Add custom attributes to outgoing links
        ::ActionView::Base.send(:include, Ajax::ActionView)
      end
    end
  end
end
