# Inspiration shamelessly stolen from
# http://gravityblast.com/2009/08/11/testing-rails-generators-with-cucumber/

require "rubygems"
gem "railties", ">= 3.0.0.beta2"

require "fileutils"
require "tempfile"

class String
  def strip_ansi
    gsub /\e\[\d+m/, ''
  end
end

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

module Helpers
  if ENV['VERBOSE'] == 'true'
    include FileUtils::Verbose
  else
    include FileUtils
  end
  
  def generate_rails_app(name = 'rails_app')
    @current_app = name
    workspace do
      run "rails #{name}"
    end
  end
  
  def add_engineer_gem
    install_engineer_gem_to_workspace_repo
    workspace @current_app do
      File.open('Gemfile', 'a') do |gemfile|
        gemfile << "gem 'engineer', '>= 0.0.0'\n"
      end
      run "GEM_HOME='#{workspace 'gemrepo'}' bundle install"
    end
  end

  def generate(generator)
    workspace @current_app do
      run "rails g #{generator}"
    end
  end

  def rake(rake_task)
    workspace @current_app do
      run "rake #{rake_task}"
    end
  end
  
  def latest_output
    @latest_output
  end
  
private

  def install_engineer_gem_to_workspace_repo
    @engineer_gem_installed_to_workspace_repo ||= begin
      repo_path = workspace 'gemrepo'
      mkdir_p repo_path
      run "GEM_HOME='#{repo_path}' gem install --no-rdoc --no-ri #{engineer_gem_file}"
      true
    end
  end

  def engineer_gem_file
    Dir["#{PROJECT_ROOT}/pkg/engineer*gem"].first
  end

  def run(cmd)
    log cmd
    (`#{cmd}`).tap do |output|
      @latest_output = output
      log output
      fail unless $?.to_i == 0
    end
  end
  
  def workspace(path = nil)
    absolute_path = path ? File.join(@workspace, path) : @workspace
    
    if block_given?
      Dir.chdir(absolute_path) do
        log "cd #{absolute_path}"
        yield
      end
    else
      absolute_path
    end
  end
  
  def log(message)
    puts message if ENV['VERBOSE'] == 'true'
  end

end

Before do
  @workspace ||= File.join(Dir::tmpdir, "engineer-cucumber-#{$$}").tap do |tmpdir|
    mkdir_p tmpdir
    at_exit { rm_rf tmpdir }
  end
end

After do
  rm_rf @workspace
end

World(Helpers)
