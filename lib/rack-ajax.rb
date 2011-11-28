require 'rack-ajax/decision_tree'
require 'rack-ajax/parser'
require 'json'
require 'yaml'
require 'yaml/encoding' unless RUBY_VERSION.to_f == 1.9

module Rack
  class Ajax
    cattr_accessor :decision_tree
    attr_accessor :user, :request, :params

    # If called with a block, executes that block as the "decision tree".
    # This is useful when testing.
    #
    # To integrate Rack::Ajax into your app you should store the decision
    # tree in a class-attribute <tt>decision_tree</tt>.
    #
    # The <tt>Rack::Ajax::DecisionTree.default_decision_tree</tt> is used if no other is provided.
    def initialize(app)
      @app = app
      @decision_tree = Proc.new if block_given?
    end

    def decision_tree
      @decision_tree ||= (self.class.decision_tree || Rack::Ajax::DecisionTree.default_decision_tree)
    end

    def call(env)
      return @app.call(env) unless ::Ajax.is_enabled?

      # Parse the Ajax-Info header
      env["Ajax-Info"] = ::Ajax.unserialize_hash(env['HTTP_AJAX_INFO'])
      @parser = Parser.new(env)
      rack_response = @parser.instance_eval(&decision_tree)

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
      # The Ajax::RSpec::Helpers module includes a helper
      # method to test the result of a rewrite.
      if ::Ajax.is_mocked?
        rack_response.nil? ? Rack::Ajax::Parser.rack_response(encode_env(env)) : rack_response
      elsif !rack_response.nil?
        rack_response
      else
        # Fallthrough to the app.
        @app.call(env)
      end
    end

    protected

    # Convert the environment hash to yaml so it can be unserialized later
    def encode_env(env)
      env = env.dup
      env['rack.session'] = env['rack.session'].to_hash if env['rack.session'].is_a?(Hash)
      env.delete_if { |k, v| k =~ /action_dispatch/ }
      env.to_yaml(:Encoding => :Utf8)
    end
  end
end
