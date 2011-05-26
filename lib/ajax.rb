require 'rack-ajax'
require 'ajax/helpers'
require 'ajax/application'
require 'ajax/routes'
require 'pathname'
# require railties at the end

module Ajax
  include Ajax::Helpers

  class << self
    attr_accessor :app
    attr_writer :logger, :framework_path
  end

  # Return the full path to the root of the Ajax plugin/gem directory.
  def self.root
    @root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end

  # Return a logger instance.
  #
  # Use the Rails logger by default, assign nil to turn off logging.
  # Dummy a logger if logging is turned off of if Ajax isn't enabled.
  def self.logger
    if !@logger.nil? && is_enabled?
      @logger
    else
      @logger = Class.new { def method_missing(*args); end; }.new
    end
  end

  # Return a boolean indicating whether the plugin is enabled.
  #
  # Enabled by default.
  def self.is_enabled?
    @enabled.nil? ? true : !!@enabled
  end
  class << self
    alias_method :enabled?, :is_enabled?
  end

  # Set to false to disable this plugin completely.
  #
  # ActionController and ActionView helpers are still mixed in but
  # they are effectively disabled, which means your code will still
  # run.
  def self.enabled=(value)
    @enabled = !!value
  end

  # Return the path to the framework page.
  #
  # Default: <tt>/ajax/framework</tt>
  def self.framework_path
    @framework_path ||= '/ajax/framework'
  end

  # Return a boolean indicating whether to enable lazy loading assets.
  # There are currently issues with some browsers when using this feature.
  #
  # Disabled by default.
  def self.lazy_load_assets?
    !!@lazy_load_assets
  end

  # Set to false to disable lazy loading assets.  Callbacks will
  # be executed immediately.
  #
  # ActionController and ActionView helpers are still mixed in but
  # they are effectively disabled, which means your code will still
  # run.
  def self.lazy_load_assets=(value)
    @lazy_load_assets = !!value
  end

  # Return a boolean indicating whether to use Google crawlable
  # URLs.
  #
  # Off by default.
  def self.google_crawlable?
    !!@google_crawlable
  end

  # Set to true to enable Google crawlable URLS i.e. /#!/.
  # The fragment must start with an exclamation point.
  def self.google_crawlable=(value)
    @google_crawlable = !!value
  end

  # Return a boolean indicating whether the plugin is being mock tested.
  #
  # Mocking forces the environment to be returned after Ajax processing
  # so that we can introspect it and verify that the correct actions were
  # taken.
  def self.is_mocked?
    @mocked ||= false
  end

  # Set to true to enable mocking testing the plugin.
  #
  # Integration tests will return the result of the URL rewriting in a
  # special response.  Redirects will be indicated using standard responses.
  #
  # Use this to test the handling of URLs in various states and with different
  # HTTP request methods.
  def self.mocked=(value)
    @mocked = !!value
  end

  def self.version
    @version ||= File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).strip
  end

  self.app = Ajax::Application.new
end

require 'ajax/railtie' if Ajax.app.rails?(3)
