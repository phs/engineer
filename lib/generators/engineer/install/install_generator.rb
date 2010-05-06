class Engineer
  module Generators
    class InstallGenerator < Rails::Generators::Base

      def self.source_root
        @source_root ||= File.expand_path('../templates', __FILE__)
      end

      def create_engine_files
        directory 'lib', 'lib'
      end

      def namespace_application_controller
        unnested_path = Rails.application.paths.app.controllers.to_a.detect do |p|
          File.exists? File.join(p, 'application_controller.rb')
        end

        return unless unnested_path

        nested_path = File.join(unnested_path, app_name)
        empty_directory nested_path

        create_file File.join(nested_path, 'application_controller.rb') do
          content = File.read File.join(unnested_path, 'application_controller.rb')
          content.gsub! "class ApplicationController", "class #{app_module}::ApplicationController"
          content
        end

        remove_file File.join(unnested_path, 'application_controller.rb')

        controller_files = Rails.application.paths.app.controllers.to_a.collect do |p|
          Dir[File.join(p, "**", "*_controller.rb")]
        end.flatten

        controller_files.reject { |f| f =~ /application_controller\.rb$/ }.each do |file|
          gsub_file file, "< ApplicationController", "< #{app_module}::ApplicationController"
        end
      end

      def append_gemspec_to_Rakefile
        in_root do
          unless IO.read('Rakefile') =~ /Engineer::Tasks.new/
            append_file 'Rakefile' do
<<-RAKE

Engineer::Tasks.new do |gem|
  gem.name = "#{app_name}"
  gem.summary = %Q{TODO: one-line summary of your engine}
  gem.description = %Q{TODO: longer description of your engine}
  gem.email = "TODO"
  gem.homepage = "TODO"
  gem.authors = ["TODO"]
  gem.require_path = 'lib'
  gem.files =  FileList[
    "[A-Z]*",
    "{app,config,lib,public,spec,test}/**/*",
    "db/**/*.rb"
  ]

  # Include Bundler dependencies
  Bundler.definition.dependencies.each do |dependency|
    next if dependency.name == "engineer"

    if (dependency.groups & [:default, :production, :staging]).any?
      gem.add_dependency dependency.name, *dependency.requirement.as_list
    else
      gem.add_development_dependency dependency.name, *dependency.requirement.as_list
    end
  end

  # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
end
RAKE
            end
          end
        end
      end

      # TODO Remove after https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4400
      def tweak_route_declaration
        gsub_file(File.join("config", "routes.rb"),
          /#{Rails.application.class}.routes.draw/, "Rails.application.routes.draw")
      end

    protected

      def app_name
        app_module.underscore
      end

      def app_module
        Rails.application.class.name.split('::').first
      end

      def engineer_version
        Gem.loaded_specs["engineer"].version
      end

    end
  end
end
