module Ajax
  module ActionController
    def self.included(klass)
      klass.class_eval do
        include ClassMethods
        alias_method_chain :render, :ajax
        after_filter :serialize_ajax_info
      end
      klass.extend(ClassMethods)
    end

    module ClassMethods

      # Set a custom response header if the request is AJAX.
      #
      # Call with <tt>key</tt> and optional <tt>value</tt>.  Pass a
      # block to yield a dynamic value.
      #
      # Accepts :only and :except conditions because we create
      # an after_filter.
      def ajax_header(*args, &block)
        return unless Ajax.is_enabled?

        options = args.extract_options!
        key, value = args.shift, args.shift
        value = block_given? ? Proc.new : value

        (self.is_a?(Class) ? self : self.class).prepend_after_filter(options) do |controller|
          if controller.request.xhr?
            value = value.is_a?(Proc) ? controller.instance_eval(&value) : value
            Ajax.set_header(controller.response, key, value)
          end
        end
      end

      # Set the layout to use for AJAX requests.
      #
      # By default we look in layouts/ajax/ for this controllers default
      # layout and render that.  If it can't be found, the default layout
      # is used.
      def ajax_layout(template_name)
        write_inheritable_attribute(:ajax_layout, template_name)
      end
    end

    protected

      if Ajax.app.rails?(3)
        # Rails 3 hook.  Rails < 3 is handled using redirect_to_full_url.  See
        # those docs for info.
        def redirect_to(url={}, status={})
          super
          self.location = nil if _ajax_redirect(url, status) # clear any location set by super
        end
      end

      # Redirect to hashed URLs unless the path is excepted.
      #
      # Store the URL that we are redirecting to in the session.
      # If we then have a request for the root URL we know
      # to render this URL instead.
      #
      # If redirecting back to the referer, use the referer
      # in the Ajax-Info header because it includes the
      # hashed part of the URL.  Otherwise the referer is
      # always the root url.
      #
      # For AJAX requests, respond with an AJAX-suitable
      # redirect.
      #
      # This method only applies to Rails < 3
      def redirect_to_full_url(url, status)
        super unless _ajax_redirect(url, status) # Only call super if we didn't handle it
      end

      # Perform special processing on the response if we need to.
      # Return true if an Ajax "redirect" was performed, and false
      # otherwise.
      def _ajax_redirect(url, status)
        return false unless Ajax.is_enabled?

        special_redirect = false
        original_url = url

        # If we have the full referrer in Ajax-Info, use that because it
        # includes the fragment.
        if url == request.headers["Referer"] && !request.headers['Ajax-Info'].blank?
          url = request.headers['Ajax-Info']['referer']
          Ajax.logger.debug("[ajax] using referer #{url} from Ajax-Info")
        end

        if !Ajax.exclude_path?(url)
          # Never redirect to the Ajax framework path, redirect to /
          if url =~ %r[#{Ajax.framework_path}]
            url = url.sub(%r[#{Ajax.framework_path}], '/')

            # Special case:
            #
            # Changing protocol forces a redirect from root to root.
            # The full request URL (including the hashed part) is
            # in the browser.  So return JS to do the redirect and
            # have it include the hashed part in the redirect URL.
            if !request.xhr? && URI.parse(url).scheme != URI.parse(request.url).scheme
              special_redirect = true
            end
          end

          if !Ajax.is_hashed_url?(url) and !Ajax.is_robot?(request.user_agent)
            url = Ajax.hashed_url_from_traditional(url)
          end
        end
        Ajax.logger.info("[ajax] rewrote redirect from #{original_url} to #{url}") unless original_url == url

        # Don't store session[:redirected_to] if doing a special redirect otherwise
        # when the next request for root comes in it will think we really want
        # to display the home page.
        if special_redirect
          session[:redirected_to] = nil
          Ajax.logger.info("[ajax] returning special redirect JS")
          self.response_body = <<END
<script type="text/javascript">
  var url = #{url.to_json};
  var hash = document.location.hash;

  // Remove leading # from the fragment
  if (hash.charAt(0) == '#') {
    hash = hash.substr(1);
  }

  // Remove leading / from the fragment if the URL already ends in a /
  // This prevents double-slashes.  Note we can't just replace all
  // double-slashes because the protocol includes //.
  if (url.charAt(url.length - 1) == '/' && hash.charAt(0) == '/') {
    hash = hash.substr(1);
  }

  document.location.href = url + hash;
</script>
END
        else
          session[:redirected_to] = url
          if request.xhr? && Ajax.is_hashed_url?(url)
            Ajax.logger.info("[ajax] detecting we are xhr. soft redirect")
            redirect_path = URI.parse(url).select(:fragment).first
            Ajax.logger.info("[ajax] redirect path is #{redirect_path}")
            Ajax.set_header(response, :soft_redirect, redirect_path)
            self.response_body = <<END
<script type="text/javascript">
  window.location.href = #{url.to_json};
</script>
END
          else
            Ajax.logger.info("[ajax] not detecting we are xhr. Hard redirect!")
            return false
          end
        end
        true
      end

      # Convert the Ajax-Info hash to JSON before the request is sent.
      # Invoked as an after filter.
      def serialize_ajax_info
        debugger
        case response.headers['Ajax-Info']
        when Hash
          response.headers['Ajax-Info'] = response.headers['Ajax-Info'].to_json
        end
      end

      #
      # Intercept rendering to customize the headers and layout handling
      #
      def render_with_ajax(options = nil, extra_options = {}, &block)
        return render_without_ajax(options, extra_options, &block) unless Ajax.is_enabled?

        original_args = [options, extra_options]
        if request.xhr?

          # Options processing taken from ActionController::Base#render
          if options.nil?
            options = { :template => default_template, :layout => true }
          elsif options == :update
            options = extra_options.merge({ :update => true })
          elsif options.is_a?(String) || options.is_a?(Symbol)
            case options.to_s.index('/')
            when 0
              extra_options[:file] = options
            when nil
              extra_options[:action] = options
            else
              extra_options[:template] = options
            end
            options = extra_options
          elsif !options.is_a?(Hash)
            extra_options[:partial] = options
            options = extra_options
          end

          default = Ajax.app.rails?(3) ? XXX : pick_layout(options)
          default = default.path_without_format_and_extension unless default.nil?
          ajax_layout = _layout_for_ajax(default)
          ajax_layout = ajax_layout.path_without_format_and_extension unless ajax_layout.nil?
          options[:layout] = ajax_layout unless ajax_layout.nil?

          # Send the current layout and controller in a custom response header
          Ajax.set_header(response, :layout, ajax_layout)
          Ajax.set_header(response, :controller, self.class.controller_name)
        end
        render_without_ajax(options, extra_options, &block)
      end

      # Return the layout to use for an AJAX request, or the default layout if one
      # cannot be found.  If no default is known, <tt>layouts/ajax/application</tt> is used.
      #
      # If no ajax_layout is set, look for the default layout in <tt>layouts/ajax</tt>.
      # If the layout cannot be found, use the default.
      #
      # FIXME: Use hard-coded html layout extension because <tt>default_template_format</tt>
      # is sometimes :js which means the layout isn't found.
      def _layout_for_ajax(default) #:nodoc:
        ajax_layout = self.class.read_inheritable_attribute(:ajax_layout)
        if ajax_layout.nil? || !(ajax_layout =~ /^layouts\/ajax/)
          find_layout("layouts/ajax/#{default.sub(/layouts(\/)?/, '')}", 'html') unless default.nil?
        else
          ajax_layout
        end
      rescue ::ActionView::MissingTemplate
        Ajax.logger.info("[ajax] no layout found in layouts/ajax using #{default}")
        default
      end
  end
end