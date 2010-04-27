require 'ajax'

include Ajax::Helpers::TaskHelper

namespace :ajax do
  desc "Install required Ajax files.  Existing files will not be overwritten."
  task :install do
    INSTALL_FILES.map do |file|
      show_result(file) { |file| copy_unless_exists(file) }
    end
  end

  namespace :install do
    desc "Copy Ajax integration spec tests into spec/integration."
    task :specs do
      puts "Coming soon..."
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