if defined?(Rails::Application)
  # Rails3 routes
  Rails.application.routes.draw do
    match Ajax.framework_path, :to => 'ajax#framework', :as => 'ajax_framework'
  end
end