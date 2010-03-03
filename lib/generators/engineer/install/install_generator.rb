module Engineer
  module Generators
    class InstallGenerator < Rails::Generators::Base

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end
      
      def copy_lib_files
        directory 'lib'
      end
      
    end
  end
end
