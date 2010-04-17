require 'rack-ajax/parser'
require 'json'

module Rack
  class Ajax
    cattr_accessor :decision_tree, :default_decision_tree
    attr_accessor :user, :request, :params

    # If called with a block, executes that block as the "decision tree".
    # This is useful when testing.
    #
    # To integrate Rack::Ajax into your app you should store the decision
    # tree in a class-attribute <tt>decision_tree</tt>.  This
    # decision tree will be used unless a block is provided.
    def initialize(app)
      @app = app
      @decision_tree = block_given? ? Proc.new : (self.class.decision_tree || self.class.default_decision_tree)
    end

    def call(env)
      return @app.call(env) unless ::Ajax.is_enabled?

      # Parse the Ajax-Info header
      if env["HTTP_AJAX_INFO"].nil?
        env["Ajax-Info"] = {}
      elsif env["HTTP_AJAX_INFO"].is_a?(String)
        env["Ajax-Info"] = (JSON.parse(env['HTTP_AJAX_INFO']) rescue {})
      end

      @parser = Parser.new(env)
      rack_response = @parser.instance_eval(&@decision_tree)

      # Clear the value of session[:redirected_to]
      unless env['rack.session'].nil?
        env['rack.session']['redirected_to'] = env['rack.session'][:redirected_to] = nil
      end

      # If we are testing our Rack::Ajax middleware, return
      # a Rack response now rather than falling through
      # to the application.
      #
      # To test rewrites, return a 200 response with
      # the modified request environment encoded as Yaml.
      #
      # The Ajax::Spec::Helpers module includes a helper
      # method to test the result of a rewrite.
      if ::Ajax.is_mocked?
        rack_response.nil? ? Rack::Ajax::Parser.rack_response(env.to_yaml) : rack_response
      elsif !rack_response.nil?
        rack_response
      else
        # Fallthrough to the app.
        @app.call(env)
      end
    ensure
      # Release the connections back to the pool.
      # @see http://blog.codefront.net/2009/06/15/activerecord-rails-metal-too-many-connections/
      ::ActiveRecord::Base.clear_active_connections! if defined?(::ActiveRecord::Base)
    end
    
    def default_decision_tree
      @@default_decision_tree ||= Proc.new do
        ::Ajax.logger.debug("[ajax] rack session #{@env['rack.session'].inspect}")
        ::Ajax.logger.debug("[ajax] Ajax-Info #{@env['Ajax-Info'].inspect}")

        if !::Ajax.exclude_path?(@env['PATH_INFO'] || @env['REQUEST_URI'])
          if ajax_request?
            if hashed_url? # the browser never sends the hashed part
              rewrite_to_traditional_url_from_fragment
            end
          else
            if url_is_root?
              if hashed_url? # the browser never sends the hashed part
                rewrite_to_traditional_url_from_fragment
              elsif get_request? && !user_is_robot?
                # When we render the framework we would like to show the
                # page the user wants on the first request.  If the
                # session has a value for <tt>redirected_to</tt> then
                # that page will be rendered.
                if redirected_to = (@env['rack.session'][:redirected_to] || @env['rack.session']['redirected_to'])
                  redirected_to = ::Ajax.is_hashed_url?(redirected_to) ? ::Ajax.traditional_url_from_fragment(redirected_to) : redirected_to
                  ::Ajax.logger.debug("[ajax] showing #{redirected_to} instead of root_url")
                  rewrite(redirected_to)
                else
                  rewrite_to_render_ajax_framework
                end
              end
            else
              if !user_is_robot?
                if hashed_url? # will never be true
                  redirect_to_hashed_url_from_fragment
                else
                  if get_request?
                    redirect_to_hashed_url_equivalent
                  end
                end
              end
            end
          end
        end
      end
  end
end
