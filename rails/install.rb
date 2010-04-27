require 'ajax'
require 'rake'

load(File.join(Ajax.root, 'tasks', 'ajax_tasks.rake'))
Rake::Task['ajax:install'].invoke