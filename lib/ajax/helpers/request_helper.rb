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
        headers = object.is_a?(Hash) ? object : object.headers # ::ActionController::Response
        key = key.to_s

        headers["Ajax-Info"] = serialize_hash(headers["Ajax-Info"]) do |info|
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

          # Set the value for this key
          info[key] = value
        end
      end

      # Return the value at key <tt>key</tt> from the <tt>Ajax-Info</tt> header
      # in <tt>object</tt>.
      #
      # <tt>object</tt> can be a Hash or instance of <tt>ActionController::Request</tt>
      # <tt>key</tt> Symbol or String hash key, converted to String
      def get_header(object, key)
        headers = object.is_a?(Hash) ? object : object.headers # ::ActionController::Request
        hash = unserialize_hash(headers && headers["Ajax-Info"])[key.to_s]
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
      def exclude_paths(paths=[], expand = true)
        if !instance_variable_defined?(:@exclude_paths)
          @exclude_paths = []
        end
        (paths.is_a?(Array) ? paths : [paths]).each do |path|
          if expand
            @exclude_paths << /^(\w+\:\/\/[^\/]+\/?)?#{path.to_s}$/
          else
            @exclude_paths << path
          end
        end
        @exclude_paths
      end

      # Directly set regexes for one or more paths that can be accessed directly without the AJAX framework.
      def exclude_regex(exclude_regex=nil)
        exclude_paths(exclude_regex, false)
      end

      # Return a boolean indicating whether or not to exclude a path from the
      # AJAX redirect.
      def exclude_path?(path)
        !!((@exclude_paths || []).find do |excluded|
          !!excluded.match(path)
        end)
      end

      # Return JSON given a Hash or JSON string.  If a block is given, yields
      # the Hash to the block so that the block can modify it before it is
      # converted to JSON.
      def serialize_hash(hash, &block)
        info = unserialize_hash(hash)
        yield info if block_given?
        info.to_json
      end

      # Return a Hash given JSON or a Hash.
      def unserialize_hash(hash)
        case hash
        when String
          JSON.parse(hash) rescue {}
        when Hash
          hash
        else
          {}
        end
      end
    end
  end
end
