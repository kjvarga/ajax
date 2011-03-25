require 'ajax/action_controller'
require 'ajax/action_view'

module Ajax
  class Railtie < Rails::Railtie
    rake_tasks do
      load(File.expand_path('../../../tasks/ajax_tasks.rake', __FILE__))
    end

    initializer 'ajax.action_integration' do
      ActiveSupport.on_load :action_view do
        include Ajax::ActionView
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