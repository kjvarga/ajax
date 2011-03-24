require 'ajax'
require 'rake'

load(Ajax.root + 'tasks/ajax_tasks.rake')
Rake::Task['ajax:install'].invoke