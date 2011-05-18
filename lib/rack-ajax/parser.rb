require 'uri'

# The <tt>rewrite</tt> and <tt>redirect</tt> methods are terminal methods meaning
# that they return a Rack response or modify the Rack request.
#
# Return <tt>nil</tt> to allow the request to fall-through to the Application.
module Rack
  class Ajax
    class Parser

      # Instantiate an ActionController::Request object to make it
      # easier to introspect the headers.
      def initialize(env)
        @env = env
        @env['rack.input'] = '' # Prevents RuntimeError: Missing rack.input
        @request = Rack::Request.new(env)
      end

      protected

      def hashed_url?
        @hashed_url ||= ::Ajax.is_hashed_url?(@env['REQUEST_URI'])
      end

      def ajax_request?
        @request.xhr?
      end

      def get_request?
        @request.get?
      end

      def post_request?
        @request.post?
      end

      def url_is_root?
        @url_is_root ||= ::Ajax.url_is_root?(@env['PATH_INFO'])
      end

      def snapshot_request?
        !!@request['_escaped_fragment_']
      end

      # Return a boolean indicating if the request is from a robot.
      # If the request is a snapshot request, the user is a robot.
      #
      # Inspects the request headers to identify robots by their
      # User-Agent string.
      #
      # Sets the result in a header {Ajax-Info}[robot] so that
      # it is available to your application.
      def user_is_robot?
        return @user_is_robot if instance_variable_defined?(:@user_is_robot)
        value =
          if snapshot_request?
            true
          elsif @request.user_agent.nil?
            false
          else
            ::Ajax.is_robot?(@request.user_agent)
          end
        self.user_is_robot = value
      end

      # Set a header indicating whether the current user is a robot
      def user_is_robot=(value)
        @user_is_robot = value
        ::Ajax.set_header(@env, :robot, @user_is_robot)
        @user_is_robot
      end

      # Google snapshot request
      def rewrite_to_traditional_url_from_escaped_fragment
        rewrite(::Ajax.traditional_url_from_escaped_fragment(@env['REQUEST_URI'], @request['_escaped_fragment_']))
      end

      def rewrite_to_traditional_url_from_fragment
        rewrite(::Ajax.traditional_url_from_fragment(@env['REQUEST_URI']))
      end

      # Redirect to a hashed URL consisting of the fragment portion of the current URL.
      # This is an edge case.  What can theoretically happen is a user visits a
      # bookmarked URL, then browses via AJAX and ends up with a URL like
      # '/Beyonce#/Akon'.  Redirect them to '/#!/Akon'.
      def redirect_to_hashed_url_from_fragment
        r302(::Ajax.hashed_url_from_fragment(@env['REQUEST_URI']))
      end

      # Redirect to the hashed URL equivalent of the current traditional URL.
      # The user has likely followed a traditional link or bookmark.
      def redirect_to_hashed_url_equivalent
        r302(::Ajax.hashed_url_from_traditional(@env['REQUEST_URI']))
      end

      def rewrite_to_render_ajax_framework
        rewrite(::Ajax.framework_path)
      end

      private

      def r302(url)
        rack_response('Redirecting...', 302, 'Location' => url)
      end

      # Expects a traditional URL.  Any fragment is ignored.
      def rewrite(url)
        uri = URI(url)
        @env['REQUEST_URI'] =  url
        @env["PATH_INFO"] =    uri.path
        @env["QUERY_STRING"] = uri.query
        nil # fallthrough to app
      end

      # You can use this method during integration testing Rack::Ajax
      # in your Rails app.  If you don't return a proper Rack response
      # during integration testing, ActiveSupport can't parse the
      # response.
      #
      # If you're testing Rack without Rails you can return base types
      # so you don't need this method.
      def self.rack_response(msg, code=200, headers={})
        headers.reverse_merge!({'Content-Type' => 'text/html'})
        [code, headers, [msg.to_s]]
      end

      def rack_response(*args)
        self.class.rack_response(*args)
      end
    end
  end
end
