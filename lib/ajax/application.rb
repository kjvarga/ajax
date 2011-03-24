require 'pathname'

module Ajax
  # A class with framework/application related methods like discovering
  # which version of Rails we are running under.
  class Application
    # Return a boolean indicating whether the Rails constant is defined.
    # Pass a <tt>version</tt> integer to determine whether the major version
    # of Rails matches <tt>version</tt>.
    #
    # Example: rails?(3) returns true when Rails.version.to_i == 3.
    #
    # Returns false if Rails is not defined or the major version does not match.
    def rails?(version=nil)
      !!(if version.nil?
        defined?(::Rails)
      elsif defined?(::Rails)
        if ::Rails.respond_to?(:version)
          ::Rails.version.to_i == version
        else
          version <= 2 # Rails.version defined in 2.1.0
        end
      else
        false
      end)
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
      if !@inititalized && rails?
        Ajax.logger = ::Rails.logger

        if rails?(3)
          require 'ajax/railtie'
        else
          # Customize rendering.  Include custom headers and don't render the layout for AJAX.
          ::ActionController::Base.send(:include, Ajax::ActionController)

          # Insert the Rack::Ajax middleware to rewrite and handle requests
          ::ActionController::Dispatcher.middleware.insert_before(Rack::Head, Rack::Ajax)

          # Add custom attributes to outgoing links
          ::ActionView::Base.send(:include, Ajax::ActionView)
        end
      end
      @inititalized ||= true
    end
  end
end