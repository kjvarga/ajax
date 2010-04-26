require 'ajax'

module Ajax
  module Routes
    # In your <tt>config/routes.rb</tt> file call:
    #   Ajax::Routes.draw(map)
    # Passing in the routing <tt>map</tt> object.
    #
    # Adds an <tt>ajax_framework_path</tt> pointing to <tt>Ajax.framework_path</tt>
    # which is <tt>/ajax/framework</tt> by default.
    def self.draw(map)
      map.ajax_framework Ajax.framework_path, :controller => 'ajax', :action => 'framework'
    end
  end
end