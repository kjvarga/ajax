module Ajax
  module ActionView
    def self.included(klass)
      klass.class_eval do
        alias_method_chain :link_to, :ajax if method_defined?(:link_to)
      end
      klass.send(:include, Helpers)
    end

    module Helpers

      # Set a custom response header if the request is AJAX.
      def ajax_header(key, value)
        return unless Ajax.is_enabled? && request.xhr?
        Ajax.set_header(response, key, value)
      end
    end

    protected

      # Include an attribute on all outgoing links to mark them as Ajax deep links.
      #
      # The deep link will be the path and query string from the href.
      #
      # To specify a different deep link pass <tt>:data-deep-link => '/deep/link/path'</tt>
      # in the <tt>link_to</tt> <tt>html_options</tt>.
      #
      # To turn off deep linking for a URL, pass <tt>:traditional => true</tt> or
      # <tt>:data-deep-link => nil</tt>.
      #
      # Any paths matching the paths in Ajax.exclude_paths will automatically be
      # linked to traditionally.
      def link_to_with_ajax(*args, &block)
        if Ajax.is_enabled? && !block_given?
          options      = args.second || {}
          html_options = args.third
          html_options = (html_options || {}).stringify_keys

          # Insert the deep link unless the URL is traditional
          if !html_options.has_key?('data-deep-link') && !html_options.delete('traditional')
            case options
            when Hash
              options[:only_path] = true
              path = url_for(options)
            else
              path = url_for(options)

              # Strip out the protocol and host from the URL
              if path =~ %r[#{root_url}]
                path.sub!(%r[#{root_url}], '/')
              end
            end

            # Don't store a data-deep-link attribute if the path is excluded
            unless Ajax.exclude_path?(path)
              html_options['data-deep-link'] = path
            end
          end
          args[2] = html_options
        end
        link_to_without_ajax(*args, &block)
      end
  end
end