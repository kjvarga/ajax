module Ajax
  module Helpers
    module UrlHelper
      # Return the URL fragment to use when building URLs, including slashes.
      # E.g. '/#/' for a traditional fragment.  Depends on the Ajax.crawlable?
      # setting.
      def fragment_string
        Ajax.crawlable? ? '/#!/' : '/#/'
      end

      # Return a boolean indicating whether the given URL points to the
      # root path.
      def url_is_root?(url)
        !!(encode_and_parse_url(url).path =~ %r[^\/?$])
      end

      # The URL is hashed if the fragment part starts with a / or a !.  This
      # distinguishes between a named anchor and an AJAXed URL.
      #
      # For example, http://lol.com#/Rihanna is hashed, but
      # http://lol.com/#Rihanna is not.
      def is_hashed_url?(url)
        !!(encode_and_parse_url(url).fragment =~ %r[^[\/\!]])
      end

      # Return a hashed URL using the fragment of <tt>url</tt>
      def hashed_url_from_fragment(url)
        url_host(url) + strip_slashes(fragment_string + normalized_url_fragment(url))
      end

      # Return a traditional URL from the fragment of <tt>url</tt>
      def traditional_url_from_fragment(url)
        url_host(url) + normalized_url_fragment(url)
      end

      # Return a hashed URL formed from a traditional <tt>url</tt>
      def hashed_url_from_traditional(url)
        uri = encode_and_parse_url(url)
        hashed_url = url_host(url) + strip_slashes(fragment_string + (uri.path || ''))
        hashed_url += ('?' + uri.query) unless uri.query.nil?
        hashed_url
      end

      def traditional_url_from_escaped_fragment(url, escaped_fragment)
        fragment = URI.decode(escaped_fragment)
        url_host(url) + strip_slashes('/' + fragment)
      end

      # Return the fragment part of the URL.  If the hashed part starts with !
      # the exclamation mark is stripped.  If there is no fragment, returns the
      # empty string.
      def url_fragment(url)
        (encode_and_parse_url(url).fragment || '').sub(/^\!/, '')
      end

      # Return the fragment part of the URL.  The result will have leading ! stripped
      # from it and is guaranteed to start with a / i.e. to be an absolute URL.
      # Uses +url_fragment*.
      def normalized_url_fragment(url)
        '/'+ url_fragment(url).sub(/^\!?\/*/, '')
      end

      protected

      # Globally replace double slashes (//) with single slashes (/) and return
      # the result.
      def strip_slashes(str)
        str.gsub(/\/\//, '/')
      end

      def encode_and_parse_url(url)
        if already_encoded?(url)
          res = URI.parse(url.gsub("%23", "#")) rescue URI.parse('/')
        else
          res = URI.parse(URI.encode(url).gsub("%23", "#")) rescue URI.parse('/')
        end
        res
      end

      def already_encoded?(url)
        URI.decode(url) != url rescue true
      end

      def url_host(url)
        if url.match(/^(\w+\:\/\/[^\/]+)\/?/)
          $1
        else
          ''
        end
      end
    end
  end
end
