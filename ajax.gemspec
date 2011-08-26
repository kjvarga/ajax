# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = %q{ajax}
  s.version     = File.read('VERSION').chomp
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Karl Varga"]
  s.email       = %q{kjvarga@gmail.com}
  s.homepage    = %q{http://github.com/kjvarga/ajax}
  s.summary     = %q{A framework to augment a traditional Rails application with a completely AJAX frontend.}
  s.description = %q{Augment a traditional Rails application with a completely AJAX frontend, while transparently handling issues important to both the enterprise and end users, such as testing, SEO and browser history.}

  s.add_development_dependency 'rspec'
  s.add_dependency 'json'
  s.add_dependency 'rack'
  s.test_files  = []
  s.files       = Dir.glob(["[A-Z]*", "init.rb", "{app,config,lib,public,rails,tasks}/**/*"]) - Dir.glob(['spec/rails*/**/*'])
end
