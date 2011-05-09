/**
*  Script lazy loader 0.5
*  Copyright (c) 2008 Bob Matsuoka
*
*  This program is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License
*  as published by the Free Software Foundation; either version 2
*  of the License, or (at your option) any later version.
*/

var LazyLoader = {}; //namespace
LazyLoader.timer = {};  // contains timers for scripts
LazyLoader.scripts = [];  // contains called script references
LazyLoader.load = function(url, callback) {
  // handle object or path
  var classname = null;
  var properties = null;
  try {
    // make sure we only load once
    if (LazyLoader.scripts.indexOf(url) == -1) {
      // note that we loaded already
      LazyLoader.scripts.push(url);
      var script = document.createElement("script");
      script.src = url;
      script.type = "text/javascript";
      $(script).appendTo("head");  // add script tag to head element

      // was a callback requested
      if (callback) {
        // test for onreadystatechange to trigger callback
        script.onreadystatechange = function () {
          if (script.readyState == 'loaded' || script.readyState == 'complete') {
            callback();
          }
        };

        // test for onload to trigger callback
        script.onload = function () {
          callback();
          return;
        };

        // safari doesn't support either onload or readystate, create a timer
        // only way to do this in safari
        if (($.browser.webkit && !navigator.userAgent.match(/Version\/3/)) || $.browser.opera) { // sniff
          LazyLoader.timer[url] = setInterval(function() {
            if (/loaded|complete/.test(document.readyState)) {
              clearInterval(LazyLoader.timer[url]);
              callback(); // call the callback handler
            }
          }, 10);
        }
      }
    } else {
      if (callback) { callback(); }
    }
  } catch (e) {
    alert(e);
  }
};

/**
 * AjaxAssets
 *
 * A class representing an Array of assets.  Call with an instance of
 * Array which will be extended with special methods.
 *
 * Example: self.javascripts = new AjaxAssets([]);
 *
 * Once an asset is loaded, it is not loaded again.  Pass with the
 * following values:
 *
 * Ajax-Info{}
 *    assets{}
 *      javascripts []
 *      stylesheets []
 *
 */
var AjaxAssets = function(array, type) {
  var DATA_URI_START = "<!--[if (!IE)|(gte IE 8)]><!-->";
  var DATA_URI_END   = "<!--<![endif]-->";
  var MHTML_START    = "<!--[if lte IE 7]>";
  var MHTML_END      = "<![endif]-->";

  return jQuery.extend(array, {
    /**
     * Add an asset, but don't load it.
     */
    addAsset: function(path) {
      this.push(this.sanitizePath(path));
    },

    /**
     * Load and add an asset.  The asset is loaded using the
     * unsanitized path should you need to put something in the
     * query string.
     */
    loadAsset: function(path, callback) {
      console.log('[ajax] loading', type, path);
      this.push(this.sanitizePath(path));
      if (type == 'css') {
        this.appendScriptTag(path, callback);
      } else if ($.browser.msie || $.browser.mozilla) {
        this.appendScriptTag(path, callback);
      } else {
        LazyLoader.load(path, callback);
      }
    },

    /**
     * Return a boolean indicating whether an asset has
     * already been loaded.
     */
    loadedAsset: function(path) {
      path = this.sanitizePath(path);
      for (var i=0; i < this.length; i++) {
        if (this[i] == path) {
          return true;
        }
      }
      return false;
    },

    /**
     * Remove query strings and otherwise cleanup paths
     * before adding them.
     */
    sanitizePath: function(path) {
      return path.replace(/\?.*/, '');
    },

    /**
     * Supports debugging and references the script files as external resources
     * rather than inline.
     *
     * @see http://stackoverflow.com/questions/690781/debugging-scripts-added-via-jquery-getscript-function
     */
    appendScriptTag: function(url, callback) {
      if (type == 'js') {
        var head = document.getElementsByTagName("head")[0];
        var script = document.createElement("script");
        script.src = url;
        script.type = 'text/javascript';
        head.appendChild(script);
        // Handle Script loading
        if (callback) {
           var done = false;
           script.onload = script.onreadystatechange = function(){
              if ( !done && (!this.readyState ||
                    this.readyState == "loaded" || this.readyState == "complete") ) {
                 done = true;
                 if (callback)
                    callback();

                 // Handle memory leak in IE
                 script.onload = script.onreadystatechange = null;
              }
           };
        }
      } else if (type == 'css') {
        if (url.match(/datauri/)) {
          $(DATA_URI_START + '<link type="text/css" rel="stylesheet" href="'+ url +'">' + DATA_URI_END).appendTo('head');
        } else if (url.match(/mhtml/)) {
          $(MHTML_START + '<link type="text/css" rel="stylesheet" href="'+ url +'">' + MHTML_END).appendTo('head');
        } else {
          $('<link type="text/css" rel="stylesheet" href="'+ url +'">').appendTo('head');
        }
      }
      return undefined;
    }
  });
};

/**
 * = Class Ajax
 *
 * == Options
 *
 * We extend self with the <tt>options</tt> array.  This allows you to set
 * any instance variable on the instance.
 *
 *    <tt>enabled</tt>  boolean indicating whether the plugin is enabled.
 *      Callbacks that you set in the Ajax-Info header or directly on
 *      this instance will still be executed.  They will not be queued,
 *      the will be executed immediately.
 *
 *    <tt>default_container</tt>  string jQuery selector of the default
 *      container element to receive content.
 *
 *    <tt>lazy_load_assets</tt>  boolean indicating whether to enable
 *      lazy loading assets.  If this is disabled, callbacks will be
 *      executed immediately.
 *
 *    <tt>show_loading_image</tt> (default true) boolean indicating whether
 *      to show the loading image.
 *
 *    <tt>loading_image</tt>  (optional) string jQuery selector of an
 *      existing image to show while pages are loading.  If not set the default
 *      selector is: img#ajax-loading
 *
 *    <tt>loading_image_path</tt> (optional) string full path to the loading
 *      image.  Used to append an image tag to the body element
 *      if an existing image is not found.  Default: /images/ajax-loading.gif
 *
 *    <tt>show_loading_image_callback</tt> (optional) a method to call to show
 *      the loading image.  Useful if you have more specific requirements as
 *      to what you want to show and how you want to show it.
 *
 *    <tt>hide_loading_image_callback</tt> (requird if you use show_loading_image_callback) a method to call to hide
 *      the loading image.  Useful if you have more specific requirements as
 *      to what you want to show and how you want to show it.
 *
 * Callbacks:
 *
 * Callbacks can be specified using Ajax-Info{ callbacks: 'javascript to eval.' },
 * or by adding callbacks directly to the Ajax instance.
 *
 * 'onLoad' callbacks are executed once new content has been inserted into the DOM,
 * and after all assets have been loaded (if using lazy-loading). I.e. "on page load".
 *
 * For example:
 *
 *    window.ajax.onLoad(function() { doSomething(args); });
 *
 * To add a callback to the front of the queue use:
 *
 *    window.ajax.prependOnLoad(function() { doSomething(args); });
 *
 * We also trigger a global 'ajax.onload' event that you can bind to to execute
 * a callback on every page load.
 *
 * KJV 2010-04-22: I've experienced problems with Safari using String callbacks.  YMMV.
 * Browser support for callbacks is patchy at this time so lazy-loading is
 * not recommended.
 */
var Ajax = function(options) {
  var self = this;

  /**
   * Options
   *
   * Extend self with the options Array.  This allows you to set any instance
   * variable on the Ajax instance.
   */
  self.options = {
    enabled: true,
    default_container: undefined,
    loaded_by_framework: false,
    show_loading_image: true,
    disable_next_address_intercept: false,
    loading_image: 'img#ajax-loading',
    loading_image_path: '/images/ajax-loading.gif',
    show_loading_image_callback: undefined, // called to show the loading image
    hide_loading_image_callback: undefined, // called to hide the loading image
    javascripts: undefined,
    stylesheets: new AjaxAssets([], 'css'),
    callbacks: [],
    loaded: false,
    lazy_load_assets: false,
    current_request: undefined,

    // For initial position of the loading icon.  Often the mouse does not
    // move so position it by the link that was clicked.
    last_click_coords: undefined
  };
  jQuery.extend(self.options, options);
  jQuery.extend(self, self.options);

  // Initialize on DOM ready
  $(function() { self.init(); });

  /**
   * Initializations run on DOM ready.
   *
   * Bind event handlers and setup jQuery Address.
   */
  self.init = function() {

    // Configure jQuery Address
    $.address.history(true);
    $.address.change = self.addressChanged;

    // Bind a live event to all ajax-enabled links
    $('a[data-deep-link]').live('click', self.linkClicked);

    // Initialize the list of javascript assets
    if (self.javascripts === undefined) {
      self.javascripts = new AjaxAssets([], 'js');

      $(document).find('script[type=text/javascript][src!=]').each(function() {
        var script = $(this);
        var src = script.attr('src');

        // Local scripts only
        if (src.match(/^\//)) {

          // Parse parameters passed to the script via the query string.
          // TODO: Untested.  It's difficult for us to use this with Jammit.
          if (src.match(/\Wajax.js\?.+/)) {
            var params = src.split('?')[1].split('&');
            jQuery.each(params, function(idx, param) {
              param = param.split('=');
              if (param.length == 1) { return true; } // continue

              switch(param[0]) {
                case 'enabled':
                  self.enabled = param[1] == 'false' ? false : true;
                  console.log('[ajax] set param enabled=', self.enabled);
                  break;
                case 'default_container':
                  self.default_container = param[1];
                  console.log('[ajax] set param default_container=', self.default_container);
                  break;
              }
              return undefined; // avoid lint warning
            });
          }

          self.javascripts.addAsset(script.attr('src'));
        }
      });
    }
    self.initialized = true;

    // Run onInit() callbacks
  };

  /**
   * jQuery Address callback triggered when the address changes.
   * Loads the current address using AJAX.
   *
   * If the inner content was pre-rendered (as in after a redirect),
   * then <tt>loaded_by_framwork</tt> should be false.
   *
   * jQuery Address will still fire a request when the page loads,
   * so we ignore that request if <tt>loaded_by_framwork</tt> is false.
   */
  self.addressChanged = function() {
    if (document.location.pathname != '/') { return false; }
    if (self.disable_next_address_intercept) {
      console.log('[ajax] skipping address intercept & resetting disable_next_address_intercept');
      self.disable_next_address_intercept = false;
      return false;
    }
    if (!self.loaded_by_framework) {
      self.loaded_by_framework = true;
      return false;
    }

    // Ensure that the URL ends with '#' if we are on root. This
    // will not trigger addressChanged().
    if (document.location.pathname == '/'
        && document.location.href.indexOf('#') == -1) {
      document.location.href = document.location.href + '#';
    }

    // Clean up the URL before making the request.  If the URL changes
    // as a result of this, update it, which will trigger this
    // callback again.
    //console.log('cleaning up the url');
    var url = ($.address.value()).replace(/\/\//, '/');
    if (url != $.address.value()) {
      console.log('[ajax] reloading because encoded uri ' + url + ' differs from current uri ' + $.address.value());
      $.address.value(url);
      return false;
    } else {
      //console.log('going ahead with load');
      self.loadPage({
        url: url
      });
    }
    return true;
  };

  /**
   * loadPage
   *
   * Request new content and insert it into the document.  If the response
   * Ajax-Info header contains any of the following we take the associated
   * action:
   *
   *  [title]      String, Set the page title
   *  [tab]        jQuery selector, trigger the 'activate' event on the tab
   *  [container]  The container to receive the content, or <tt>main</tt> by default.
   *  [assets]     Assets to load
   *  [callbacks]  Execute one or more callbacks after assets have loaded
   *
   *  Cookies in the response are automatically set on the document.cookie.
   *
   *  Options:
   *    url      request url (required)
   *    method   request method, default GET
   *    data     request data
   */
  self.loadPage = function(options) {
    if (!self.enabled) {
      document.location.href = options.url;
      return true;
    }

    if (options.url === undefined) {
      console.log('[ajax] no url supplied ');
      return false;
    };

    self.loaded = false;
    self.showLoadingImage();
    console.log('[ajax] loadPage ' + options.url);

    if (self.current_request !== undefined) {
      self.abortCurrentRequest();
    }

    if ($.browser.msie) {
      safe_url = encodeURI(options.url);
    } else {
      safe_url = options.url;
    };

    self.current_request = jQuery.ajax({
      cache: false,
      url: safe_url,
      data: options.data,
      type: options.method ? options.method : 'GET',
      beforeSend: self.setRequestHeaders,
      success: self.responseHandler,
      dataType: 'html',
      complete: function(XMLHttpRequest, responseText) {
        // Scroll to the top of the page.
        $(document).scrollTop(0);
        self.hideLoadingImage();
        self.loaded = true;
        self.current_request = undefined;
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        var responseText = XMLHttpRequest.responseText;
        self.responseHandler(responseText, textStatus, XMLHttpRequest);
      }
    });
    return true;
  };


  /**
   * abortCurrentRequest
   *
   * Abort the current ajax request
   */
  self.abortCurrentRequest = function() {
    try {
      if (self.current_request.url) {
        console.log('[ajax] aborting current request for url ' + self.current_request.url);
      }
      self.current_request.abort();
    } catch(e) {
      console.log('[ajax] abort failed!', e);
    };
  };

  /**
   * setRequestHeaders
   *
   * Set the AJAX_INFO request header.  This includes all the data
   * defined on the main (or receiving) container, plus some other
   * useful information like the:
   *
   * referer - the current document.location
   *
   */
  self.setRequestHeaders = function(XMLHttpRequest) {
    var data = $(self.default_container).data('ajax-info');
    if (data === undefined || data === null) { data = {}; }
    data['referer'] = document.location.href;
    XMLHttpRequest.setRequestHeader('AJAX_INFO', $.toJSON(data));
  };

  /**
   * host
   *
   * Return the current host with protocol and with no trailing slash.
   */
  self.host = function() {
    return $.address.baseURL().replace(new RegExp(document.location.pathname), '');
  };

  /**
   * linkClicked
   *
   * Called when the an AJAX-enabled link is clicked.
   * Redirect back to the root URL if we are not on it.
   *
   */
  self.linkClicked = function(event) {
    // The deep link must be a path.  A full URL shouldn't have
    // made it through, but sometimes it can happen.  In this
    // case, strip off the host and protocol.
    if ($(this).attr('href') == '#') return false;
    ajax_url = $(this).attr('data-deep-link');
    if (ajax_url.match(/^https?:\/\//)) {
      ajax_url = ajax_url.replace(/(https?:\/\/[^\/]*\/(.*))/, '$2');
    }
    if (document.location.pathname != '/') {
      var url = ('/#/' + ajax_url).replace(/\/\//, '/');
      //console.log('linkClicked 1: going to ' + url);
      document.location.href = url;
    } else {
      self.last_click_coords = { pageX: event.pageX, pageY: event.pageY };
      encoded_url = ajax.safeURL(ajax_url);
      //console.log('linkClicked 2: going to ' + ajax_url);
      //console.log('untouched url is ' + ajax_url + ', encoded is ' + encoded_url);
      if ($.browser.msie) {
        $.address.value(encoded_url);
      }
      else {
        $.address.value(ajax_url);
      }
    }
    return false;
  };

  self.safeURL = function(url) {
    if (decodeURI(url)==url) {
      encoded_url = encodeURI(url);
    } else {
      encoded_url = url;
    };
    return encoded_url;
  };

  /**
   * responseHandler
   *
   * Process the response of an AJAX call and put the contents in
   * the appropriate container, activate tabs etc.
   *
   */
  self.responseHandler = function(responseText, textStatus, XMLHttpRequest) {

    self.last_request_object = XMLHttpRequest;
    console.log("[ajax] in response handler! status: " + self.last_request_object.status);
    if(self.last_request_object.status == 0) {
      console.log("[ajax] aborting response handler! ");
      return;
    }
    var data = self.processResponseHeaders(XMLHttpRequest);

    if (data.soft_redirect !== undefined) {
      console.log('[ajax] issuing soft redirect to ' + data.soft_redirect);
      $.address.value(data.soft_redirect);
      return;
    };

    var container = data.container === undefined ? $(self.default_container) : $(data.container);
    /**
     * Full page response.  The best we can do is to extract the body
     * and display that.  Additionally, if the container to update
     * is present in the response, just use that.
     */
    if (responseText.search(/<\s*body[^>]*>/) != -1) {
      var start = responseText.search(/<\s*body[^>]*>/);
      start += responseText.match(/<\s*body[^>]*>/)[0].length;
      var end   = responseText.search(/<\s*\/\s*body\s*\>/);

      console.log('[ajax] extracted body ['+start+'..'+end+'] chars');
      responseText = responseText.substr(start, end - start);

      var body = $(responseText);
      if (body.size() > 0 && body.find(container.selector).size() > 0) {
        responseText = body.find(container.selector).html();
      }
    }

    // Handle special header instructions
    //  title    - set page title
    //  tab      - activate a tab
    //  assets   - load assets
    //  callbacks - execute one or an array of callbacks
    if (data.title !== undefined) {
      console.log('[ajax] set page title '+data.title);
      // commenting this out until we fix ' char bug, removing % chars from page titles for now
      // $.address.title(encodeURIComponent(data.title));
      $.address.title(data.title);
    }

    if (data.tab !== undefined) {
      console.log('[ajax] activated tab '+data.tab);
      $(data.tab).trigger('activate');
    }

    /**
     * Load stylesheets
    */
    if (self.lazy_load_assets && data.assets && data.assets.stylesheets !== undefined) {
      jQuery.each(jQuery.makeArray(data.assets.stylesheets), function(idx, url) {
        if (self.stylesheets.loadedAsset(url)) {
          console.log('[ajax] skipping css', url);
          return true; // continue
        } else {
          self.stylesheets.loadAsset(url);
        }
        return undefined;
      });
    }

    /**
     * Insert response
    */
    console.log('[ajax] using container ', container.selector);
    console.log('[ajax] got ajax-info ', data);
    container.data('ajax-info', data);
    container.html(responseText);

    /**
     * Include callbacks from Ajax-Info
    */
    if (data.callbacks) {
      data.callbacks = jQuery.makeArray(data.callbacks);
      self.callbacks = self.callbacks.concat(data.callbacks);
    }

    /**
     * Load javascipts
    */
    if (self.lazy_load_assets && data.assets && data.assets.javascripts !== undefined) {
      var count = data.assets.javascripts.length;
      var callback;

      jQuery.each(jQuery.makeArray(data.assets.javascripts), function(idx, url) {
        if (self.javascripts.loadedAsset(url)) {
          console.log('[ajax] skipping js', url);
          return true; // continue
        }

        // Execute callbacks once the last asset has loaded
        callback = (idx == count - 1) ? undefined : self.executeCallbacks;
        self.javascripts.loadAsset(url, callback);
        return undefined;
      });
    } else {
      // Execute callbacks immediately
      self.executeCallbacks();
    }

    $(document).trigger('ajax.onload');

    /**
     * Set cookies - browsers don't seem to allow this
    */
    try {
      var cookie = XMLHttpRequest.getResponseHeader('Set-Cookie');
      if (cookie !== null) {
        console.log('[ajax] attempting to set cookie');
        document.cookie = cookie;
      }
    } catch(e) {
    }
  };

  /**
   * Process the response headers.
   *
   * Set the page title.
   */
  self.processResponseHeaders = function(XMLHttpRequest) {
    var data = XMLHttpRequest.getResponseHeader('Ajax-Info');
    if (data !== null) {
      try { data = jQuery.parseJSON(data); }
      catch(e) {
        console.log('[ajax] failed to parse Ajax-Info header as JSON!', data);
      }
    }
    if (data === null || data === undefined) {
      data = {};
    }
    return data;
  };

  /**
   * Hide the loading image.
   *
   * Stop watching the mouse position.
   */
  self.hideLoadingImage = function() {
    // check if a new request has already started
    if (self.current_request && self.current_request.status == 0) {
      console.log("[ajax] aborting hideLoadingImage.. ");
      return;
    }
    if (!self.show_loading_image) { return; }
    if (!self.hide_loading_image_callback) {
      $(document).unbind('mousemove', self.updateImagePosition);
      $(self.loading_image).hide();
    } else {
      self.hide_loading_image_callback();
    }
  };

  /**
   * Show the loading image.
   */
  self.showLoadingImage = function() {
    if (!self.show_loading_image) { return; }
    if (!self.show_loading_image_callback) {
      var icon = $(self.loading_image);

      // Create the image if it doesn't exist
      if (icon.size() == 0)  {
        $('<img src="'+ self.loading_image_path +'" id="ajax-loading" alt="Loading..." />').hide().appendTo($('body'));
        icon = $(self.loading_image);
      }

      // Follow the mouse pointer
      $(document).bind('mousemove', self.updateImagePosition);

      // Display at last click coords initially
      if (self.last_click_coords !== undefined) {
        self.updateImagePosition(self.last_click_coords);

      // Center it
      } else {
        var marginTop  = parseInt(icon.css('marginTop'), 10);
        var marginLeft = parseInt(icon.css('marginLeft'), 10);
        marginTop      = isNaN(marginTop)  ? 0 : marginTop;
        marginLeft     = isNaN(marginLeft) ? 0 : marginLeft;

        icon.css({
          position:   'absolute',
          left:       '50%',
          top:        '50%',
          zIndex:     '99',
          marginTop:  marginTop  + jQuery(window).scrollTop(),
          marginLeft: marginLeft + jQuery(window).scrollLeft()
        });
      }
      icon.show();

    } else {
      self.show_loading_image_callback();
    }
  };

  /**
   * Update the position of the loading icon.
   */
  self.updateImagePosition = function(e) {
    $(self.loading_image).css({
      zIndex:   99,
      position: 'absolute',
      top:      e.pageY + 14,
      left:     e.pageX + 14
    });
  };

  /**
   * onLoad
   *
   * Register a callback to be executed in the global scope
   * once all Ajax assets have been loaded.  Callbacks are
   * appended to the queue.
   *
   * If the plugin is disabled, callbacks are executed immediately
   * on DOM ready.
   */
  self.onLoad = function(callback) {
    if (self.enabled && (self.lazy_load_assets && !self.loaded)) {
      self.callbacks.push(callback);
      console.log('[ajax] appending callback', self.teaser(callback));
    } else {
      self.executeCallback(callback, true);
    }
  };

  /**
   * prependOnLoad
   *
   * Add a callback to the start of the queue.
   *
   * @see onLoad
   */
  self.prependOnLoad = function(callback) {
    if (self.enabled && (self.lazy_load_assets && !self.loaded)) {
      self.callbacks.unshift(callback);
      console.log('[ajax] prepending callback', self.teaser(callback));
    } else {
      self.executeCallback(callback, true);
    }
  };

  /**
   * Execute callbacks
  */
  self.executeCallbacks = function() {
    var callbacks = jQuery.makeArray(self.callbacks);
    if (callbacks.length > 0) {
      jQuery.each(callbacks, function(idx, callback) {
        self.executeCallback(callback);
      });
      self.callbacks = [];
    }
  };

  /**
   * Execute a callback given as a string or function reference.
   *
   * <tt>dom_ready</tt> (optional) boolean, if true, the callback
   * is wrapped in a DOM-ready jQuery callback.
   */
  self.executeCallback = function(callback, dom_ready) {
    if (dom_ready !== undefined && dom_ready) {
      $(function() {
        self.executeCallback(callback);
      });
    } else {
      console.log('[ajax] executing callback', self.teaser(callback));
      try {
        if (jQuery.isFunction(callback)) {
          callback();
        } else {
          jQuery.globalEval(callback);
        }
      } catch(e) {
        console.log('[ajax] callback failed with exception', e);
      }
    }
  };

  self.teaser = function(callback) {
    return new String(callback).slice(0,200).replace(/\n/g, ' ');
  };

  /**
   * Escape all special jQuery CSS selector characters in *selector*.
   * Useful when you have a class or id which contains special characters
   * which you need to include in a selector.
   */
  self.escapeSelector = (function() {
    var specials = [
      '#', '&', '~', '=', '>',
      "'", ':', '"', '!', ';', ','
    ];
    var regexSpecials = [
      '.', '*', '+', '|', '[', ']', '(', ')', '/', '^', '$'
    ];
    var sRE = new RegExp(
      '(' + specials.join('|') + '|\\' + regexSpecials.join('|\\') + ')', 'g'
    );

    return function(selector) {
      return selector.replace(sRE, '\\$1');
    };
  })();
};