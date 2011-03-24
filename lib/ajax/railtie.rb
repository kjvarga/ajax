module Ajax
  class Railtie < Rails::Railtie
    rake_tasks do
      load(File.expand_path('../../../tasks/ajax_tasks.rake', __FILE__))
    end

    initializer 'ajax.insert_into_action_classes' do
      ActiveSupport.on_load :action_view do
        ActionView::Base.send :include, Ajax::ActionView
      end
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send :include, Ajax::ActionController
      end
    end

    initializer "ajax.configure" do |app|
      app.config.middleware.insert_before "Rack::Head", "Rack::Ajax"
    end
  end
end