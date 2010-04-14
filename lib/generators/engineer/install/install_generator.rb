class Engineer
  module Generators
    class InstallGenerator < Rails::Generators::Base

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end
      
      def copy_lib_files
        directory 'lib'
      end
      
      def append_gemspec_to_Rakefile
        in_root do
          unless IO.read('Rakefile') =~ /Engineer::Tasks.new/
            puts app_name
            append_file 'Rakefile' do
<<-RAKE

Engineer::Tasks.new do |gem|
  gem.name = "#{app_name}"
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
  gem.email = "TODO"
  gem.homepage = "TODO"
  gem.authors = ["TODO"]
  gem.require_path = '.'
  gem.files =  FileList[
    "[A-Z]*",
    "{app,config,lib,public,spec,test,vendor}/**/*",
    "db/**/*.rb"
  ]
  # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
end
RAKE
            end
          end
        end
      end

    protected

      def app_name
        Rails.application.class.name.split('::').first.underscore
      end

    end
  end
end
