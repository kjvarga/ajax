Dir[File.join(File.dirname(__FILE__), 'helpers', '*')].map do |file|
  require file
end

module Ajax #:nodoc:
  module Helpers #:nodoc:
    def self.included(klass)
      klass.class_eval do
        extend RequestHelper
        extend RobotHelper
        extend UrlHelper
      end     
    end
  end
end