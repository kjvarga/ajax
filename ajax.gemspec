# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ajax}
  s.version = "1.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Karl Varga"]
  s.date = %q{2011-05-11}
  s.description = %q{Augment a traditional Rails application with a completely AJAX frontend, while transparently handling issues important to both the enterprise and end users, such as testing, SEO and browser history.}
  s.email = %q{kjvarga@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
     "Gemfile.lock",
     "MIT-LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "app/controllers/ajax_controller.rb",
     "app/views/ajax/framework.html.erb",
     "app/views/layouts/ajax/application.html.erb",
     "config/initializers/ajax.rb",
     "init.rb",
     "lib/ajax.rb",
     "lib/ajax/action_controller.rb",
     "lib/ajax/action_view.rb",
     "lib/ajax/application.rb",
     "lib/ajax/helpers.rb",
     "lib/ajax/helpers/request_helper.rb",
     "lib/ajax/helpers/robot_helper.rb",
     "lib/ajax/helpers/task_helper.rb",
     "lib/ajax/helpers/url_helper.rb",
     "lib/ajax/railtie.rb",
     "lib/ajax/routes.rb",
     "lib/ajax/rspec.rb",
     "lib/ajax/rspec/extension.rb",
     "lib/ajax/rspec/helpers.rb",
     "lib/ajax/tasks.rb",
     "lib/rack-ajax.rb",
     "lib/rack-ajax/decision_tree.rb",
     "lib/rack-ajax/parser.rb",
     "public/images/ajax-loading.gif",
     "public/javascripts/ajax.js",
     "public/javascripts/jquery.address-1.3.js",
     "public/javascripts/jquery.address-1.3.min.js",
     "public/javascripts/jquery.json-2.2.js",
     "public/javascripts/jquery.json-2.2.min.js",
     "rails/init.rb",
     "rails/install.rb",
     "rails/routes.rb",
     "tasks/ajax_tasks.rake"
  ]
  s.homepage = %q{http://github.com/kjvarga/ajax}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A framework to augment a traditional Rails application with a completely AJAX frontend.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<rack>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<rack>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<rack>, [">= 0"])
  end
end

