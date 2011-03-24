require 'ajax'

include Ajax::Helpers::TaskHelper

namespace :ajax do
  desc "Install required Ajax files.  Existing files will not be overwritten."
  task :install do
    INSTALL_FILES.map do |file|
      show_result(file) { |file| copy_unless_exists(file) }
    end
    puts <<-END
\nWelcome to Ajax!

1. Ajax looks for an alternative layout to use with AJAX requests in
<tt>app/views/layouts/ajax/</tt>. Copy existing layouts into this directory and get them
ready for AJAX by removing any HTML HEAD elements, everything but the inner BODY content.

 Your main layout should contain a container element that will receive page content.
Typically this would be the container below the page header. If you don't have a static
header, you can make the whole BODY element the container.

 Here is an example of converting our layouts/application.html.haml to
layouts/ajax/application.html.haml:
http://gist.github.com/373133/5a80a63ef69a883ed3c5630b68330b1036ad01ec.

2. Instantiate an instance of the Ajax class in public/javascripts/application.js. For
example:

  // public/javascripts/application.js
  if (typeof(Ajax) != 'undefined') {
    window.ajax = new Ajax({
      default_container: '#main',  // jQuery selector of your container element
      enabled: true,               // Enable/disable the plugin
      lazy_load_assets: false      // YMMV
    });
  }
END
  end

  namespace :install do
    desc "Copy Ajax integration spec tests into spec/integration."
    task :specs do
      file = Ajax.app.root + 'spec/integration/ajax_spec.rb'
      if File.exist?(file)
        puts "already exists: #{file}" if verbose
      else
        FileUtils.mkdir_p(File.dirname(file))
        FileUtils.cp(file.sub(Ajax.app.root, Ajax.root), file)
        puts "created: #{file}" if verbose
      end
    end
  end

  namespace :update do
    desc "Overwrite public/javascripts/ajax.js with the latest version."
    task :javascript do
      UPDATE_JAVASCRIPT_FILES.map do |file|
        show_result(file) { |file| copy_and_overwrite(file) }
      end
    end
  end
end