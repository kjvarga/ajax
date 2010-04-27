require 'json'

module Ajax
  module Helpers
    module RequestHelper
      # Recursive merge values
      DEEP_MERGE = lambda do |key, v1, v2|
        if v1.is_a?(Hash) && v2.is_a?(Hash)
          v1.merge(v2, &DEEP_MERGE)
        elsif v1.is_a?(Array) && v2.is_a?(Array)
          v1.concat(v2)
        else
          [v1, v2].compact.first
        end
      end

      # Set the value at <tt>key</tt> in the <tt>Ajax-Info</tt> header
      # in <tt>object</tt>.
      #
      # <tt>object</tt> can be a Hash or instance of <tt>ActionController::Request</tt>
      # <tt>key</tt> Symbol or String hash key, converted to String
      # <tt>value</tt> any value that con be converted to JSON
      #
      # All Hash and Array values are deep-merged.
      # Hash keys are converted to Strings.
      def set_header(object, key, value)
        headers = object.is_a?(::ActionController::Response) ? object.headers : object
        key = key.to_s

        info = case headers["Ajax-Info"]
        when String
          JSON.parse(headers["Ajax-Info"]) rescue {}
        when Hash
          headers["Ajax-Info"]
        else
          {}
        end

        # Deep merge hashes
        if info.has_key?(key) &&
            value.is_a?(Hash) &&
            info[key].is_a?(Hash)
          value = value.stringify_keys!
          value = info[key].merge(value, &DEEP_MERGE)
        end

        # Concat arrays
        if info.has_key?(key) &&
            value.is_a?(Array) &&
            info[key].is_a?(Array)
          value = info[key].concat(value)
        end

        info[key] = value
        headers["Ajax-Info"] = info.to_json
      end

      # Return the value at key <tt>key</tt> from the <tt>Ajax-Info</tt> header
      # in <tt>object</tt>.
      #
      # <tt>object</tt> can be a Hash or instance of <tt>ActionController::Request</tt>
      # <tt>key</tt> Symbol or String hash key, converted to String
      def get_header(object, key)
        headers = object.is_a?(::ActionController::Request) ? object.headers : object
        key = key.to_s

        info = case headers["Ajax-Info"]
        when String
          JSON.parse(headers["Ajax-Info"]) rescue {}
        when Hash
          headers["Ajax-Info"]
        else
          {}
        end
        info[key]
      end

      # Set one or more paths that can be accessed directly without the AJAX framework.
      #
      # Useful for excluding pages with HTTPS content on them from being loaded
      # via AJAX.
      #
      # <tt>paths</tt> a list of String or Regexp instances that are matched
      # against each REQUEST_PATH.
      #
      # The string and regex paths are modified to match full URLs by prepending
      # them with the appropriate regular expression.
      def exclude_paths(paths=nil)
        if !instance_variable_defined?(:@exclude_paths)
          @exclude_paths = []
        end
        (paths || []).each do |path|
          @exclude_paths << /^(\w+\:\/\/[^\/]+\/?)?#{path.to_s}$/
        end
        @exclude_paths
      end

      # Return a boolean indicating whether or not to exclude a path from the
      # AJAX redirect.
      def exclude_path?(path)
        !!((@exclude_paths || []).find do |excluded|
          !!excluded.match(path)
        end)
      end
    end
  end
end