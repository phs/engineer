class Engineer
  module Generators
    class InstallGenerator < Rails::Generators::Base

      def self.source_root
        @source_root ||= File.expand_path('../templates', __FILE__)
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
  gem.require_path = 'lib'
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

      # TODO: Unneeded once https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4400 is applied
      def tweak_route_declaration
        gsub_file File.join("config", "routes.rb"), /^.*::Application.routes.draw/, "Rails.application.routes.draw"
      end

      def create_install_generator
        directory 'install_generator', File.join("lib", "generators", app_name, "install")
      end

    protected

      def app_name
        Rails.application.class.name.split('::').first.underscore
      end

    end
  end
end
