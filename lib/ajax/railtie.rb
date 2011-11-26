require 'ajax/action_controller'
require 'ajax/action_view'
require 'ajax/action_view_renderer' if Ajax.app.rails?(:>=, 3.1)

module Ajax
  class Railtie < Rails::Railtie
    rake_tasks do
      load(File.expand_path('../../../tasks/ajax_tasks.rake', __FILE__))
    end

    initializer 'ajax.action_integration' do
      ActiveSupport.on_load :action_view do
        include Ajax::ActionView

        if Ajax.app.rails?(:<, 3.1)
          self.class_eval do
            if !instance_methods.include?('_render_layout_with_tracking')
              def _render_layout_with_tracking(layout, locals, &block)
                controller.instance_variable_set(:@_rendered_layout, layout)
                _render_layout_without_tracking(layout, locals, &block)
              end
              alias_method_chain :_render_layout, :tracking
            end
          end
        end
      end
      ActiveSupport.on_load :action_controller do
        include Ajax::ActionController
      end
    end

    initializer "ajax.middleware" do |app|
      app.config.middleware.insert_before "ActionDispatch::Head", "Rack::Ajax"
    end

    initializer 'ajax.routes' do |app|
      app.routes_reloader.paths << Ajax.root + 'rails/routes.rb'
    end

    initializer 'ajax.logger' do |app|
      Ajax.logger = ::Rails.logger
    end
  end
end
