require 'rake'
require 'rake/rdoctask'
require 'rubygems'
gem 'rspec', '1.3.0'
require 'spec/rake/spectask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ajax"
    gem.summary = %Q{A framework to augment a traditional Rails application with a completely AJAX frontend.}
    gem.description = %Q{Augment a traditional Rails application with a completely AJAX frontend, while transparently handling issues important to both the enterprise and end users, such as testing, SEO and browser history.}
    gem.email = "kjvarga@gmail.com"
    gem.homepage = "http://github.com/kjvarga/ajax"
    gem.authors = ["Karl Varga"]
    gem.files =  FileList["[A-Z]*", "{app,config,lib,public,rails,spec,tasks}/**/*"]
    gem.test_files = []
    gem.add_development_dependency "rspec"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc 'Default: run spec tests.'
task :default => :spec

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/ajax/**/*_spec.rb', 'spec/rack-ajax/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

#task :spec => :check_dependencies

desc 'Generate documentation for the ajax plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Ajax'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('app/**/*.rb')
end

namespace :release do

  desc "Release a new patch version"
  task :patch do
    Rake::Task['version:bump:patch'].invoke
    Rake::Task['release:current'].invoke
  end

  desc "Release the current version (e.g. after a version bump).  This rebuilds the gemspec, pushes the updated code, tags it and releases to RubyGems"
  task :current do
    Rake::Task['github:release'].invoke
    Rake::Task['git:release'].invoke
    Rake::Task['gemcutter:release'].invoke
  end
end