module Ajax
  module Routes
    # In your <tt>config/routes.rb</tt> file call:
    #   Ajax::Routes.draw(map)
    # Passing in the routing <tt>map</tt> object.
    #
    # Adds an <tt>ajax_framework_path</tt> pointing to <tt>Ajax.framework_path</tt>
    # which is <tt>/ajax/framework</tt> by default.
    #
    # Only applies when installed as a gem in Rails 2 or less.
    def self.draw(map)
      if Ajax.app.rails?(3) && map.respond_to?(:match)
        map.match Ajax.framework_path, :to => 'ajax#framework', :as => 'ajax_framework'
      else
        map.ajax_framework Ajax.framework_path, :controller => 'ajax', :action => 'framework'
      end
    end
  end
end