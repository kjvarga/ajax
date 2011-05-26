require 'uri'

module Ajax
  module RSpec
    module Helpers
      def self.included(receiver)
        receiver.send(:include, ::Ajax::RSpec::FileHelpers)
        receiver.send(:include, ::Ajax::RSpec::OptionHelpers)
        receiver.send(:extend,  ::Ajax::RSpec::OptionHelpers)
      end
    end

    module RequestHelpers
      def create_app
        @app = Class.new { def call(env); true; end }.new
      end

      def call_rack(url, request_method='GET', env={}, &block)
        env(url, request_method, env)
        @rack = Rack::Ajax.new(@app, &block)
        @response = @rack.call(@env)
      end

      def should_respond_with(msg)
        should_be_a_valid_response
        response_body.should == msg
      end

      def should_redirect_to(location, code=302)
        should_be_a_valid_response
        response_code.should == code
        response_headers['Location'].should == location
      end

      def should_set_ajax_response_header(key, value)
        response_headers['Ajax-Info'][key].should == value
      end

      def should_set_ajax_request_header(key, value)
        Ajax.get_header(@env, key).should == value
      end

      def should_rewrite_to(url)
        should_be_a_valid_response

        # Check custom headers
        response_body_as_hash['REQUEST_URI'].should == url
      end

      def should_not_modify_request
        should_be_a_valid_response
        response_code.should == 200

        # If we have the original headers from a call to call_rack()
        # check that they haven't changed.  Otherwise, just make sure
        # that we don't have the custom rewrite header.
        if !@env.nil?
          @env.each { |k,v| response_body_as_hash.should == v }
        end
      end

      # Response must be [code, {headers}, ['Response']]
      # Headers must contain the Content-Type header
      def should_be_a_valid_response
        return if !@response.is_a?(Array) # ::ActionController::Response
        @response.should be_a(Array)
        @response.size.should == 3
        @response[0].should be_a(Integer)
        @response[1].should be_a(Hash)
        @response[1]['Content-Type'].should =~ %r[^text\/\w+]
        @response[2].should be_a(Array)
        @response[2][0].should be_a(String)
      end

      def env(uri, request_method, options={})
        uri = URI.parse(uri)
        @env = {
          'REQUEST_URI' => uri.to_s,
          'PATH_INFO' => uri.path,
          'QUERY_STRING' => uri.query,
          'REQUEST_METHOD' => request_method
        }.merge!(options)
      end

      def response_body
        @response.is_a?(Array) ? @response[2][0] : @response.body
      end

      def response_code
        @response.is_a?(Array) ? @response[0] : @response.status.to_i
      end

      def response_headers
        @response.is_a?(Array) ? @response[1] : @response.headers.to_hash
      end

      def response_body_as_hash
        @response_body_as_hash ||= YAML.load(response_body)
      end
    end

    module FileHelpers
      def files_should_be_identical(first, second)
        identical_files?(first, second).should be(true)
      end

      def files_should_not_be_identical(first, second)
        identical_files?(first, second).should be(false)
      end

      def file_should_exist(file)
        File.exists?(file).should be(true)
      end

      def file_should_not_exist(file)
        File.exists?(file).should be(false)
      end

      def identical_files?(first, second)
        open(second, 'r').read.should == open(first, 'r').read
      end
    end

    module OptionHelpers
      # Set one or more options from the +opts+ hash on the Ajax object
      # and return an array of their original values.
      def set_option(opts)
        opts.collect do |option, value|
          original = Ajax.send("#{option}?")
          Ajax.send("#{option}=", value)
          original
        end
      end

      # Sets the options on Ajax, yields to the block and then restores the original
      # options after the block completes.
      def with_option(opts, yields=nil, &block)
        original = set_option(opts)
        yields.nil? ? yield : yield(yields)
        set_option(opts.keys.zip(original))
      end

      # Pass an array of values for each option.  Each value is set on the
      # Ajax object before yielding to the block.
      #
      # Pass an array of values to yield to the block in +yields+.  If it's empty,
      # no value will be yielded.
      def with_each_option(opts, yields=[], &block)
        until opts.values.first.empty?
          with_option(opts.inject({}) do |hash, tuple|
            hash[tuple.first] = opts[tuple.first].shift
            hash
          end, yields.shift, &block)
        end
      end
    end
  end
end
