require 'bundler/setup'
Bundler.require

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ajax"
    gem.summary = %Q{A framework to augment a traditional Rails application with a completely AJAX frontend.}
    gem.description = %Q{Augment a traditional Rails application with a completely AJAX frontend, while transparently handling issues important to both the enterprise and end users, such as testing, SEO and browser history.}
    gem.email = "kjvarga@gmail.com"
    gem.homepage = "http://github.com/kjvarga/ajax"
    gem.authors = ["Karl Varga"]
    gem.files =  FileList["[A-Z]*", "init.rb", "{app,config,lib,public,rails,tasks}/**/*"] - FileList['spec/rails*/**/*']
    gem.test_files = []
    gem.add_development_dependency "rspec"
    gem.add_dependency "json"
    gem.add_dependency "rack"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc 'Default: run spec tests.'
task :default => :spec

# Don't run spec/integration tests.  They are for your Rails application and require
# rspec-rails.
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/ajax/**/*_spec.rb', 'spec/rack-ajax/**/*_spec.rb']
  spec.rspec_opts = ['--backtrace']
end

#
# Helpers
#

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  File.read('VERSION').chomp
end

def gem_file
  "#{name}-#{version}.gem"
end

#
# Release Tasks
# @see https://github.com/mojombo/rakegem
#

desc "Create tag v#{version}, build the gem and push to Git"
task :release => :build do
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end
  sh "git commit --allow-empty -a -m 'Release #{version}'"
  sh "git tag v#{version}"
  sh "git push origin master"
  #sh "git push origin v#{version}" # don't release gem
end

desc "Build #{gem_file} into the pkg directory"
task :build => :gemspec do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end
