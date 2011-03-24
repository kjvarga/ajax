module Ajax
  module Helpers
    module TaskHelper
      INSTALL_FILES = %w[
        app/controllers/ajax_controller.rb
        app/views/ajax/framework.html.erb
        config/initializers/ajax.rb
        public/javascripts/ajax.js
        public/javascripts/jquery.address-1.3.js
        public/javascripts/jquery.address-1.3.min.js
        public/javascripts/jquery.json-2.2.min.js
        public/images/ajax-loading.gif]

      UPDATE_JAVASCRIPT_FILES = %w[
        public/javascripts/ajax.js]

      def copy_unless_exists(file, from_dir=Ajax.root, to_dir=Rails.root)
        from_file, to_file = File.join(from_dir, file), File.join(to_dir, file)
        if File.exist?(to_file)
          return false
        else
          FileUtils.mkdir_p(File.dirname(to_file)) unless File.directory?(File.dirname(to_file))
          FileUtils.cp(from_file, to_file)
          return true
        end
      rescue Exception => e
        e
      end

      def copy_and_overwrite(file, from_dir=Ajax.root, to_dir=Rails.root)
        from_file, to_file = File.join(from_dir, file), File.join(to_dir, file)
        FileUtils.mkdir_p(File.dirname(to_file)) unless File.directory?(File.dirname(to_file))
        FileUtils.cp(from_file, to_file)
        return true
      rescue Exception => e
        e
      end

      def show_result(file)
        result = yield file
        return unless verbose

        case result
        when Exception
          puts "skipped: #{file} #{result.message}"
        when true
          puts "created: #{file}"
        else
          puts "skipped: #{file}"
        end
      end
    end
  end
end