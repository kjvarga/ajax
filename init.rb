begin
  require File.expand_path('../lib/ajax', __FILE__) # From here
rescue LoadError
  require 'ajax' # from gem
end
Ajax.app.init